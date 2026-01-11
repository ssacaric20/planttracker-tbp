-- ============================================
-- PlantTracker Database Triggers
-- Aktivne baze podataka - automatizacija
-- ============================================

-- ============================================
-- FUNKCIJE ZA OKIDAČE
-- ============================================

-- Funkcija za automatsko ažuriranje updated_at polja
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za automatsko evidentiranje promjena statusa u povijest
CREATE OR REPLACE FUNCTION track_plant_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Zatvori prethodni period ako postoji
    UPDATE plant_status_history
    SET valid_to = CURRENT_TIMESTAMP
    WHERE plant_id = NEW.plant_id
      AND valid_to IS NULL;
    
    -- Kreiraj novi zapis u povijesti
    INSERT INTO plant_status_history (plant_id, status, valid_from, changed_by, notes)
    VALUES (NEW.plant_id, NEW.current_status, CURRENT_TIMESTAMP, CURRENT_USER, 'Status promijenjen');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za automatsko generiranje notifikacija za dospjele podsjetnika
CREATE OR REPLACE FUNCTION generate_reminder_notifications()
RETURNS TRIGGER AS $$
DECLARE
    plant_name VARCHAR(100);
BEGIN
    -- Dohvati ime biljke
    SELECT common_name INTO plant_name
    FROM plants
    WHERE plant_id = NEW.plant_id;
    
    -- Generiraj notifikaciju ako je podsjetnik aktivan i dospjeli
    IF NEW.is_active = TRUE AND NEW.next_due <= CURRENT_TIMESTAMP THEN
        INSERT INTO notifications (reminder_id, plant_id, message, created_at)
        VALUES (
            NEW.reminder_id,
            NEW.plant_id,
            format('Vrijeme je za %s biljke "%s"', NEW.reminder_type, plant_name),
            CURRENT_TIMESTAMP
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za automatsko ažuriranje podsjetnika nakon događaja
CREATE OR REPLACE FUNCTION update_reminder_after_event()
RETURNS TRIGGER AS $$
DECLARE
    matching_reminder RECORD;
    next_date TIMESTAMP;
BEGIN
    -- Pronađi aktivne podsjetnika za ovu biljku i tip događaja
    FOR matching_reminder IN 
        SELECT * FROM reminders
        WHERE plant_id = NEW.plant_id
          AND reminder_type = NEW.event_type
          AND is_active = TRUE
    LOOP
        -- Izračunaj sljedeći datum ovisno o frekvenciji
        next_date := NEW.event_date + 
            CASE matching_reminder.frequency
                WHEN 'dnevno' THEN INTERVAL '1 day'
                WHEN 'tjedno' THEN INTERVAL '7 days'
                WHEN 'dvotjedno' THEN INTERVAL '14 days'
                WHEN 'mjesečno' THEN INTERVAL '30 days'
            END;
        
        -- Ažuriraj podsjetnik
        UPDATE reminders
        SET last_performed = NEW.event_date,
            next_due = next_date
        WHERE reminder_id = matching_reminder.reminder_id;
        
        -- Označi postojeće notifikacije kao pročitane
        UPDATE notifications
        SET is_read = TRUE,
            read_at = CURRENT_TIMESTAMP
        WHERE reminder_id = matching_reminder.reminder_id
          AND is_read = FALSE;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za evidentiranje inicijalnog statusa nove biljke
CREATE OR REPLACE FUNCTION initialize_plant_status()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO plant_status_history (plant_id, status, valid_from, changed_by, notes)
    VALUES (NEW.plant_id, NEW.current_status, CURRENT_TIMESTAMP, CURRENT_USER, 'Inicijalni status');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za provjeru i upozorenje na neobično dugo vrijeme bez zalijevanja
CREATE OR REPLACE FUNCTION check_watering_interval()
RETURNS TRIGGER AS $$
DECLARE
    last_watering TIMESTAMP;
    days_without_water INTEGER;
BEGIN
    -- Pronađi zadnje zalijevanje
    SELECT MAX(event_date) INTO last_watering
    FROM events
    WHERE plant_id = NEW.plant_id
      AND event_type = 'zalijevanje'
      AND event_id < NEW.event_id;
    
    -- Ako postoji prethodna zalijevanje, provjeri interval
    IF last_watering IS NOT NULL THEN
        days_without_water := EXTRACT(DAY FROM (NEW.event_date - last_watering));
        
        -- Ako je prošlo više od 14 dana, kreiraj upozorenje
        IF days_without_water > 14 THEN
            INSERT INTO notifications (plant_id, message, created_at)
            VALUES (
                NEW.plant_id,
                format('Upozorenje: Prošlo je %s dana između zalijevanja!', days_without_water),
                CURRENT_TIMESTAMP
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- OKIDAČI (TRIGGERS)
-- ============================================

-- Okidač za automatsko ažuriranje updated_at polja u tablici plants
CREATE TRIGGER trigger_update_plant_timestamp
    BEFORE UPDATE ON plants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Okidač za praćenje promjena statusa biljaka (temporalne baze)
CREATE TRIGGER trigger_track_status_change
    AFTER UPDATE OF current_status ON plants
    FOR EACH ROW
    WHEN (OLD.current_status IS DISTINCT FROM NEW.current_status)
    EXECUTE FUNCTION track_plant_status_change();

-- Okidač za inicijalizaciju povijesti statusa nove biljke
CREATE TRIGGER trigger_initialize_status
    AFTER INSERT ON plants
    FOR EACH ROW
    EXECUTE FUNCTION initialize_plant_status();

-- Okidač za generiranje notifikacija iz podsjetnika (aktivne baze)
CREATE TRIGGER trigger_generate_notifications
    AFTER INSERT OR UPDATE ON reminders
    FOR EACH ROW
    EXECUTE FUNCTION generate_reminder_notifications();

-- Okidač za automatsko ažuriranje podsjetnika nakon događaja (aktivne baze)
CREATE TRIGGER trigger_update_reminder
    AFTER INSERT ON events
    FOR EACH ROW
    EXECUTE FUNCTION update_reminder_after_event();

-- Okidač za provjeru intervala zalijevanja
CREATE TRIGGER trigger_check_watering
    AFTER INSERT ON events
    FOR EACH ROW
    WHEN (NEW.event_type = 'zalijevanje')
    EXECUTE FUNCTION check_watering_interval();

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON FUNCTION update_updated_at_column() IS 'Automatski ažurira polje updated_at pri modificiranju zapisa';
COMMENT ON FUNCTION track_plant_status_change() IS 'Evidentira promjene statusa biljaka u temporalnu tablicu povijesti';
COMMENT ON FUNCTION generate_reminder_notifications() IS 'Generira notifikacije za dospjele podsjetnika - aktivne baze';
COMMENT ON FUNCTION update_reminder_after_event() IS 'Automatski ažurira podsjetnika nakon izvršenog događaja - aktivne baze';
COMMENT ON FUNCTION initialize_plant_status() IS 'Inicijalizira povijest statusa za novu biljku';
COMMENT ON FUNCTION check_watering_interval() IS 'Provjerava neobično duge intervale između zalijevanja i generira upozorenja';

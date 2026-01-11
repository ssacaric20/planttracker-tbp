-- ============================================
-- PlantTracker Database Functions
-- Napredne funkcije i stored procedure
-- ============================================

-- ============================================
-- TEMPORALNE FUNKCIJE
-- ============================================

-- Funkcija za dohvaćanje statusa biljke u određenom vremenskom trenutku
CREATE OR REPLACE FUNCTION get_plant_status_at(
    p_plant_id UUID,
    p_timestamp TIMESTAMP
)
RETURNS plant_status AS $$
DECLARE
    result plant_status;
BEGIN
    SELECT status INTO result
    FROM plant_status_history
    WHERE plant_id = p_plant_id
      AND valid_from <= p_timestamp
      AND (valid_to IS NULL OR valid_to > p_timestamp)
    ORDER BY valid_from DESC
    LIMIT 1;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za dohvaćanje povijesti statusa biljke u određenom vremenskom razdoblju
CREATE OR REPLACE FUNCTION get_status_history(
    p_plant_id UUID,
    p_from_date TIMESTAMP,
    p_to_date TIMESTAMP
)
RETURNS TABLE (
    status plant_status,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    duration INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        psh.status,
        psh.valid_from,
        COALESCE(psh.valid_to, CURRENT_TIMESTAMP) AS valid_to,
        COALESCE(psh.valid_to, CURRENT_TIMESTAMP) - psh.valid_from AS duration
    FROM plant_status_history psh
    WHERE psh.plant_id = p_plant_id
      AND psh.valid_from <= p_to_date
      AND (psh.valid_to IS NULL OR psh.valid_to >= p_from_date)
    ORDER BY psh.valid_from;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ANALITIČKE FUNKCIJE
-- ============================================

-- Funkcija za izračun prosječnog intervala između zalijevanja
CREATE OR REPLACE FUNCTION calculate_avg_watering_interval(
    p_plant_id UUID
)
RETURNS INTERVAL AS $$
DECLARE
    avg_interval INTERVAL;
BEGIN
    SELECT AVG(event_date - LAG(event_date) OVER (ORDER BY event_date))
    INTO avg_interval
    FROM events
    WHERE plant_id = p_plant_id
      AND event_type = 'zalijevanje';
    
    RETURN avg_interval;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za dohvaćanje statistike rasta biljke
CREATE OR REPLACE FUNCTION get_growth_statistics(
    p_plant_id UUID
)
RETURNS TABLE (
    total_measurements INTEGER,
    avg_height DECIMAL,
    max_height DECIMAL,
    height_growth DECIMAL,
    avg_leaf_count DECIMAL,
    measurement_span INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER AS total_measurements,
        AVG(height_cm) AS avg_height,
        MAX(height_cm) AS max_height,
        MAX(height_cm) - MIN(height_cm) AS height_growth,
        AVG(leaf_count) AS avg_leaf_count,
        MAX(measurement_date) - MIN(measurement_date) AS measurement_span
    FROM growth_measurements
    WHERE plant_id = p_plant_id;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za dohvaćanje trenda rasta
CREATE OR REPLACE FUNCTION get_growth_trend(
    p_plant_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    measurement_date TIMESTAMP,
    height_cm DECIMAL,
    height_change DECIMAL,
    leaf_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gm.measurement_date,
        gm.height_cm,
        gm.height_cm - LAG(gm.height_cm) OVER (ORDER BY gm.measurement_date) AS height_change,
        gm.leaf_count
    FROM growth_measurements gm
    WHERE gm.plant_id = p_plant_id
      AND gm.measurement_date >= CURRENT_TIMESTAMP - (p_days || ' days')::INTERVAL
    ORDER BY gm.measurement_date;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNKCIJE ZA IZVJEŠTAJE
-- ============================================

-- Funkcija za generiranje izvještaja o aktivnostima biljke
CREATE OR REPLACE FUNCTION generate_plant_report(
    p_plant_id UUID
)
RETURNS TABLE (
    plant_name VARCHAR,
    status plant_status,
    total_events INTEGER,
    last_watered TIMESTAMP,
    last_fertilized TIMESTAMP,
    days_since_planting INTEGER,
    active_reminders INTEGER,
    total_images INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.common_name,
        p.current_status,
        COUNT(DISTINCT e.event_id)::INTEGER AS total_events,
        MAX(CASE WHEN e.event_type = 'zalijevanje' THEN e.event_date END) AS last_watered,
        MAX(CASE WHEN e.event_type = 'gnojenje' THEN e.event_date END) AS last_fertilized,
        EXTRACT(DAY FROM AGE(CURRENT_TIMESTAMP, p.planting_date))::INTEGER AS days_since_planting,
        COUNT(DISTINCT CASE WHEN r.is_active = TRUE THEN r.reminder_id END)::INTEGER AS active_reminders,
        COUNT(DISTINCT i.image_id)::INTEGER AS total_images
    FROM plants p
    LEFT JOIN events e ON p.plant_id = e.plant_id
    LEFT JOIN reminders r ON p.plant_id = r.plant_id
    LEFT JOIN images i ON p.plant_id = i.plant_id
    WHERE p.plant_id = p_plant_id
    GROUP BY p.plant_id, p.common_name, p.current_status, p.planting_date;
END;
$$ LANGUAGE plpgsql;

-- Funkcija za pregled svih biljaka s ključnim informacijama
CREATE OR REPLACE FUNCTION get_plants_overview()
RETURNS TABLE (
    plant_id UUID,
    common_name VARCHAR,
    scientific_name VARCHAR,
    status plant_status,
    location VARCHAR,
    days_old INTEGER,
    next_reminder TIMESTAMP,
    needs_attention BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.plant_id,
        p.common_name,
        p.scientific_name,
        p.current_status,
        p.location,
        EXTRACT(DAY FROM AGE(CURRENT_TIMESTAMP, p.planting_date))::INTEGER AS days_old,
        MIN(r.next_due) AS next_reminder,
        CASE 
            WHEN MIN(r.next_due) <= CURRENT_TIMESTAMP THEN TRUE
            WHEN p.current_status IN ('bolesna', 'uvenula') THEN TRUE
            ELSE FALSE
        END AS needs_attention
    FROM plants p
    LEFT JOIN reminders r ON p.plant_id = r.plant_id AND r.is_active = TRUE
    GROUP BY p.plant_id, p.common_name, p.scientific_name, p.current_status, p.location, p.planting_date
    ORDER BY needs_attention DESC, next_reminder;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedura za kreiranje podsjetnika za zalijevanje s pametnim intervalom
CREATE OR REPLACE PROCEDURE create_smart_watering_reminder(
    p_plant_id UUID,
    p_frequency reminder_frequency DEFAULT 'tjedno'
)
LANGUAGE plpgsql AS $$
DECLARE
    avg_interval INTERVAL;
    suggested_frequency reminder_frequency;
    next_date TIMESTAMP;
BEGIN
    -- Izračunaj prosječni interval zalijevanja
    avg_interval := calculate_avg_watering_interval(p_plant_id);
    
    -- Predloži frekvenciju na temelju povijesti
    IF avg_interval IS NOT NULL THEN
        IF avg_interval <= INTERVAL '2 days' THEN
            suggested_frequency := 'dnevno';
        ELSIF avg_interval <= INTERVAL '10 days' THEN
            suggested_frequency := 'tjedno';
        ELSIF avg_interval <= INTERVAL '20 days' THEN
            suggested_frequency := 'dvotjedno';
        ELSE
            suggested_frequency := 'mjesečno';
        END IF;
    ELSE
        suggested_frequency := p_frequency;
    END IF;
    
    -- Izračunaj sljedeći datum
    next_date := CURRENT_TIMESTAMP + 
        CASE suggested_frequency
            WHEN 'dnevno' THEN INTERVAL '1 day'
            WHEN 'tjedno' THEN INTERVAL '7 days'
            WHEN 'dvotjedno' THEN INTERVAL '14 days'
            WHEN 'mjesečno' THEN INTERVAL '30 days'
        END;
    
    -- Kreiraj podsjetnik
    INSERT INTO reminders (plant_id, reminder_type, frequency, next_due)
    VALUES (p_plant_id, 'zalijevanje', suggested_frequency, next_date);
    
    RAISE NOTICE 'Kreiran podsjetnik za zalijevanje s frekvencijom: %', suggested_frequency;
END;
$$;

-- Procedura za arhiviranje starih podataka (održavanje performansi)
CREATE OR REPLACE PROCEDURE archive_old_data(
    p_days_to_keep INTEGER DEFAULT 365
)
LANGUAGE plpgsql AS $$
DECLARE
    cutoff_date TIMESTAMP;
    deleted_count INTEGER;
BEGIN
    cutoff_date := CURRENT_TIMESTAMP - (p_days_to_keep || ' days')::INTERVAL;
    
    -- Arhiviraj stare notifikacije koje su pročitane
    DELETE FROM notifications
    WHERE is_read = TRUE 
      AND read_at < cutoff_date;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Arhivirano % starih notifikacija', deleted_count;
    
    -- Dodatne operacije arhiviranja mogu se dodati ovdje
END;
$$;

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON FUNCTION get_plant_status_at(UUID, TIMESTAMP) IS 'Dohvaća status biljke u određenom vremenskom trenutku - temporalne baze';
COMMENT ON FUNCTION get_status_history(UUID, TIMESTAMP, TIMESTAMP) IS 'Dohvaća potpunu povijest statusa biljke u vremenskom razdoblju';
COMMENT ON FUNCTION calculate_avg_watering_interval(UUID) IS 'Izračunava prosječni interval između zalijevanja';
COMMENT ON FUNCTION get_growth_statistics(UUID) IS 'Dohvaća statističke podatke o rastu biljke';
COMMENT ON FUNCTION get_growth_trend(UUID, INTEGER) IS 'Analizira trend rasta biljke u zadnjih N dana';
COMMENT ON FUNCTION generate_plant_report(UUID) IS 'Generira detaljni izvještaj o biljci';
COMMENT ON FUNCTION get_plants_overview() IS 'Dohvaća pregled svih biljaka s ključnim informacijama';
COMMENT ON PROCEDURE create_smart_watering_reminder(UUID, reminder_frequency) IS 'Kreira pametan podsjetnik za zalijevanje na temelju povijesti';
COMMENT ON PROCEDURE archive_old_data(INTEGER) IS 'Arhivira stare podatke za održavanje performansi';

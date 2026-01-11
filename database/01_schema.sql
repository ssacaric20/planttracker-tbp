-- ============================================
-- PlantTracker Database Schema
-- Aktivne i temporalne baze podataka
-- ============================================

-- Kreiranje ekstenzija
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ============================================
-- ENUMERATION TYPES
-- ============================================

CREATE TYPE plant_status AS ENUM ('zdrava', 'bolesna', 'uvenula', 'cvatnja', 'mirovanje');
CREATE TYPE event_type AS ENUM ('zalijevanje', 'gnojenje', 'presađivanje', 'rezanje', 'bolest', 'napomena');
CREATE TYPE reminder_frequency AS ENUM ('dnevno', 'tjedno', 'dvotjedno', 'mjesečno');

-- ============================================
-- TABLICE
-- ============================================

-- Tablica biljaka
CREATE TABLE plants (
    plant_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150),
    variety VARCHAR(100),
    location VARCHAR(200),
    planting_date DATE NOT NULL,
    acquisition_source VARCHAR(200),
    current_status plant_status DEFAULT 'zdrava',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Temporalna tablica za povijest statusa biljaka
CREATE TABLE plant_status_history (
    history_id SERIAL PRIMARY KEY,
    plant_id UUID REFERENCES plants(plant_id) ON DELETE CASCADE,
    status plant_status NOT NULL,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT NULL,
    changed_by VARCHAR(100),
    notes TEXT,
    CONSTRAINT valid_period_check CHECK (valid_to IS NULL OR valid_to > valid_from)
);

-- Indeks za temporalno pretraživanje
CREATE INDEX idx_status_history_temporal ON plant_status_history 
    USING GIST (plant_id, tsrange(valid_from, valid_to));

-- Tablica događaja
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    plant_id UUID REFERENCES plants(plant_id) ON DELETE CASCADE,
    event_type event_type NOT NULL,
    event_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    amount VARCHAR(50), -- npr. "200ml", "10g"
    performed_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indeks za brže pretraživanje događaja po biljci i tipu
CREATE INDEX idx_events_plant_type ON events(plant_id, event_type);
CREATE INDEX idx_events_date ON events(event_date DESC);

-- Tablica podsjetnika (aktivne baze - okidači)
CREATE TABLE reminders (
    reminder_id SERIAL PRIMARY KEY,
    plant_id UUID REFERENCES plants(plant_id) ON DELETE CASCADE,
    reminder_type event_type NOT NULL,
    frequency reminder_frequency NOT NULL,
    last_performed TIMESTAMP,
    next_due TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablica notifikacija (generiranih okidačima)
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    reminder_id INTEGER REFERENCES reminders(reminder_id) ON DELETE CASCADE,
    plant_id UUID REFERENCES plants(plant_id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

CREATE INDEX idx_notifications_unread ON notifications(is_read, created_at);

-- Tablica slika
CREATE TABLE images (
    image_id SERIAL PRIMARY KEY,
    plant_id UUID REFERENCES plants(plant_id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    caption TEXT,
    taken_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_images_plant ON images(plant_id, taken_at DESC);

-- Tablica mjerenja rasta (temporalni podaci)
CREATE TABLE growth_measurements (
    measurement_id SERIAL PRIMARY KEY,
    plant_id UUID REFERENCES plants(plant_id) ON DELETE CASCADE,
    height_cm DECIMAL(6,2),
    width_cm DECIMAL(6,2),
    leaf_count INTEGER,
    flower_count INTEGER,
    measurement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_measurements_plant_date ON growth_measurements(plant_id, measurement_date DESC);

-- ============================================
-- VIEWS (Pogledi)
-- ============================================

-- Pogled aktivnih podsjetnika koji su dospiječi
CREATE VIEW overdue_reminders AS
SELECT 
    r.reminder_id,
    r.plant_id,
    p.common_name,
    r.reminder_type,
    r.next_due,
    CURRENT_TIMESTAMP - r.next_due AS overdue_by,
    r.notes
FROM reminders r
JOIN plants p ON r.plant_id = p.plant_id
WHERE r.is_active = TRUE 
  AND r.next_due <= CURRENT_TIMESTAMP
ORDER BY r.next_due;

-- Pogled za trenutni status svake biljke
CREATE VIEW current_plant_status AS
SELECT 
    p.plant_id,
    p.common_name,
    p.scientific_name,
    p.current_status,
    psh.valid_from AS status_since,
    AGE(CURRENT_TIMESTAMP, p.planting_date) AS plant_age,
    p.location
FROM plants p
LEFT JOIN plant_status_history psh ON p.plant_id = psh.plant_id 
    AND psh.valid_to IS NULL;

-- Pogled za statistiku događaja po biljci
CREATE VIEW plant_event_stats AS
SELECT 
    p.plant_id,
    p.common_name,
    COUNT(CASE WHEN e.event_type = 'zalijevanje' THEN 1 END) AS watering_count,
    COUNT(CASE WHEN e.event_type = 'gnojenje' THEN 1 END) AS fertilizing_count,
    MAX(CASE WHEN e.event_type = 'zalijevanje' THEN e.event_date END) AS last_watered,
    MAX(CASE WHEN e.event_type = 'gnojenje' THEN e.event_date END) AS last_fertilized,
    COUNT(DISTINCT DATE(e.event_date)) AS active_days
FROM plants p
LEFT JOIN events e ON p.plant_id = e.plant_id
GROUP BY p.plant_id, p.common_name;

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE plants IS 'Osnovna tablica za pohranu informacija o biljkama';
COMMENT ON TABLE plant_status_history IS 'Temporalna tablica za praćenje promjena statusa biljaka kroz vrijeme';
COMMENT ON TABLE events IS 'Tablica za evidentiranje svih događaja vezanih uz biljke';
COMMENT ON TABLE reminders IS 'Tablica podsjetnika za aktivne baze podataka';
COMMENT ON TABLE notifications IS 'Tablica notifikacija generiranih okidačima';
COMMENT ON TABLE images IS 'Tablica za pohranu putanja do slika biljaka';
COMMENT ON TABLE growth_measurements IS 'Temporalna tablica za praćenje rasta biljaka';

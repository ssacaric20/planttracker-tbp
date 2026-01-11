-- ============================================
-- PlantTracker Sample Data
-- Testni podaci za demonstraciju
-- ============================================

-- ============================================
-- BILJKE
-- ============================================

INSERT INTO plants (plant_id, common_name, scientific_name, variety, location, planting_date, acquisition_source, current_status, notes) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Monstera', 'Monstera deliciosa', 'Swiss Cheese Plant', 'Dnevna soba', '2024-01-15', 'Vrtni centar Zagreb', 'zdrava', 'Velika biljka s lijepim listovima'),
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'Aloe Vera', 'Aloe barbadensis miller', 'Medicinska aloa', 'Balkon', '2024-03-20', 'Poklon od prijatelja', 'zdrava', 'Koristi se za kožu'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'Bazilika', 'Ocimum basilicum', 'Genovese', 'Kuhinja - prozor', '2024-06-01', 'Sjeme iz OBI-a', 'cvatnja', 'Za kulinarske potrebe'),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Paprena metvica', 'Mentha × piperita', '', 'Vanjski vrt', '2024-04-10', 'Sadnica iz rasadnika', 'zdrava', 'Za čaj i koktele'),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'Leptir orhideja', 'Phalaenopsis', 'Pink', 'Spavaća soba', '2024-02-14', 'Valentinovo poklon', 'mirovanje', 'Prošla cvatnja, čeka novu');

-- ============================================
-- DOGAĐAJI
-- ============================================

-- Monstera događaji
INSERT INTO events (plant_id, event_type, event_date, description, amount) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'zalijevanje', '2024-12-21 09:00:00', 'Redovno zalijevanje', '300ml'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'zalijevanje', '2024-12-14 09:15:00', 'Redovno zalijevanje', '300ml'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'zalijevanje', '2024-12-07 10:00:00', 'Redovno zalijevanje', '250ml'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'gnojenje', '2024-12-01 11:00:00', 'Tekuće gnojivo za zelene biljke', '5ml'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'rezanje', '2024-11-15 14:00:00', 'Uklonjeni smeđi listovi', NULL),

-- Aloe Vera događaji
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'zalijevanje', '2024-12-15 10:00:00', 'Rijetko zalijevanje - sukulenta', '100ml'),
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'zalijevanje', '2024-11-30 10:30:00', 'Rijetko zalijevanje', '100ml'),
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'presađivanje', '2024-10-05 15:00:00', 'Presađena u veću posudu', NULL),

-- Bazilika događaji
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'zalijevanje', '2024-12-20 08:00:00', 'Svakodnevno zalijevanje', '50ml'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'zalijevanje', '2024-12-19 08:00:00', 'Svakodnevno zalijevanje', '50ml'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'gnojenje', '2024-12-10 09:00:00', 'Organsko gnojivo', '3ml'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'rezanje', '2024-12-18 12:00:00', 'Berba listova za pesto', NULL),

-- Metvica događaji
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'zalijevanje', '2024-12-19 09:00:00', 'Zalijevanje', '200ml'),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'zalijevanje', '2024-12-16 09:00:00', 'Zalijevanje', '200ml'),

-- Orhideja događaji
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'zalijevanje', '2024-12-18 10:00:00', 'Potapanje u vodu 15 min', NULL),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'zalijevanje', '2024-12-11 10:00:00', 'Potapanje u vodu 15 min', NULL),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'napomena', '2024-11-20 16:00:00', 'Zadnji cvijet je uveo', NULL);

-- ============================================
-- PODSJETNICI
-- ============================================

INSERT INTO reminders (plant_id, reminder_type, frequency, last_performed, next_due, is_active) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'zalijevanje', 'tjedno', '2024-12-21 09:00:00', '2024-12-28 09:00:00', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'gnojenje', 'mjesečno', '2024-12-01 11:00:00', '2024-12-31 11:00:00', TRUE),

('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'zalijevanje', 'dvotjedno', '2024-12-15 10:00:00', '2024-12-29 10:00:00', TRUE),

('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'zalijevanje', 'dnevno', '2024-12-20 08:00:00', '2024-12-21 08:00:00', TRUE),

('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'zalijevanje', 'tjedno', '2024-12-19 09:00:00', '2024-12-26 09:00:00', TRUE),

('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'zalijevanje', 'tjedno', '2024-12-18 10:00:00', '2024-12-25 10:00:00', TRUE);

-- ============================================
-- MJERENJA RASTA
-- ============================================

-- Monstera rast
INSERT INTO growth_measurements (plant_id, height_cm, width_cm, leaf_count, measurement_date, notes) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 45.0, 40.0, 8, '2024-01-20 12:00:00', 'Početno mjerenje'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 52.0, 45.0, 10, '2024-03-15 12:00:00', 'Dva nova lista'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 61.0, 52.0, 12, '2024-06-10 12:00:00', 'Odličan rast'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 68.0, 58.0, 14, '2024-09-05 12:00:00', 'Stabilan rast'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 73.0, 62.0, 15, '2024-12-01 12:00:00', 'Zima - sporiji rast'),

-- Bazilika rast
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 5.0, 3.0, 6, '2024-06-08 10:00:00', 'Nicanje'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 12.0, 8.0, 18, '2024-07-01 10:00:00', 'Brzi rast'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 22.0, 15.0, 32, '2024-08-15 10:00:00', 'Bujna biljka'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 28.0, 18.0, 28, '2024-10-20 10:00:00', 'Nakon nekoliko berbi'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 25.0, 20.0, 35, '2024-12-15 10:00:00', 'Cijela i zdrava');

-- ============================================
-- SLIKE (putanje do datoteka)
-- ============================================

INSERT INTO images (plant_id, file_path, caption, taken_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '/images/monstera_2024_01_20.jpg', 'Monstera nakon kupnje', '2024-01-20 13:00:00'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '/images/monstera_2024_06_10.jpg', 'Monstera s novim listovima', '2024-06-10 14:00:00'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '/images/monstera_2024_12_01.jpg', 'Aktualna Monstera', '2024-12-01 11:00:00'),

('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', '/images/aloe_2024_03_20.jpg', 'Aloe nakon presađivanja', '2024-10-05 16:00:00'),

('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', '/images/basil_2024_08_15.jpg', 'Bazilika u punom cvatu', '2024-08-15 12:00:00'),

('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', '/images/orchid_2024_02_14.jpg', 'Orhideja u cvatnji', '2024-02-20 10:00:00'),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', '/images/orchid_2024_11_20.jpg', 'Orhideja nakon cvatnje', '2024-11-20 16:30:00');

-- ============================================
-- TESTIRANJE TEMPORALNIH UPITA
-- ============================================

-- Simulacija promjena statusa kroz vrijeme
UPDATE plants SET current_status = 'bolesna' WHERE plant_id = 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15';
UPDATE plants SET current_status = 'mirovanje' WHERE plant_id = 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15';

-- ============================================
-- INFORMACIJE
-- ============================================

-- Ispis statistike
DO $$
DECLARE
    plant_count INTEGER;
    event_count INTEGER;
    reminder_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO plant_count FROM plants;
    SELECT COUNT(*) INTO event_count FROM events;
    SELECT COUNT(*) INTO reminder_count FROM reminders;
    
    RAISE NOTICE '====================================';
    RAISE NOTICE 'PlantTracker - Sample Data učitani';
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Ukupno biljaka: %', plant_count;
    RAISE NOTICE 'Ukupno događaja: %', event_count;
    RAISE NOTICE 'Aktivnih podsjetnika: %', reminder_count;
    RAISE NOTICE '====================================';
END $$;

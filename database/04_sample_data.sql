-- ============================================
-- PlantTracker data
-- Testni podaci za demonstraciju
-- ============================================

-- ============================================
-- BILJKE
-- ============================================

INSERT INTO plants (plant_id, common_name, scientific_name, variety, location, planting_date, acquisition_source, current_status, notes) VALUES
(1, 'Monstera', 'Monstera deliciosa', 'Swiss Cheese Plant', 'Dnevna soba', '2025-03-15', 'Vrtni centar Zagreb', 'zdrava', 'Velika biljka s lijepim listovima'),
(2, 'Aloe Vera', 'Aloe barbadensis miller', 'Medicinska aloa', 'Balkon', '2025-05-20', 'Poklon od prijatelja', 'zdrava', 'Koristi se za kožu'),
(3, 'Bazilika', 'Ocimum basilicum', 'Genovese', 'Kuhinja - prozor', '2025-08-01', 'Sjeme iz OBI-a', 'cvatnja', 'Za kulinarske potrebe'),
(4, 'Paprena metvica', 'Mentha × piperita', '', 'Vanjski vrt', '2025-06-10', 'Sadnica iz rasadnika', 'zdrava', 'Za čaj i koktele'),
(5, 'Leptir orhideja', 'Phalaenopsis', 'Pink', 'Spavaća soba', '2025-04-14', 'Valentinovo poklon', 'mirovanje', 'Prošla cvatnja, čeka novu');

-- Postavi sequence na sljedeći ID
SELECT setval('plants_plant_id_seq', 5, true);

-- ============================================
-- DOGAĐAJI
-- ============================================

-- Monstera događaji (ID=1)
INSERT INTO events (plant_id, event_type, event_date, description, amount) VALUES
(1, 'zalijevanje', '2026-01-15 09:00:00', 'Redovno zalijevanje', '300ml'),
(1, 'zalijevanje', '2026-01-08 09:15:00', 'Redovno zalijevanje', '300ml'),
(1, 'zalijevanje', '2026-01-01 10:00:00', 'Prvo zalijevanje u novoj godini', '250ml'),
(1, 'zalijevanje', '2025-12-25 10:00:00', 'Zalijevanje za Božić', '300ml'),
(1, 'zalijevanje', '2025-12-18 09:00:00', 'Redovno zalijevanje', '300ml'),
(1, 'zalijevanje', '2025-12-11 09:30:00', 'Redovno zalijevanje', '280ml'),
(1, 'gnojenje', '2025-12-01 11:00:00', 'Tekuće gnojivo za zelene biljke', '5ml'),
(1, 'gnojenje', '2025-11-01 10:00:00', 'Tekuće gnojivo', '5ml'),
(1, 'rezanje', '2025-11-15 14:00:00', 'Uklonjeni smeđi listovi', NULL),
(1, 'zalijevanje', '2025-11-05 09:00:00', 'Redovno zalijevanje', '300ml'),
(1, 'zalijevanje', '2025-10-28 09:00:00', 'Redovno zalijevanje', '300ml'),

-- Aloe Vera događaji (ID=2)
(2, 'zalijevanje', '2026-01-10 10:00:00', 'Rijetko zalijevanje - sukulenta', '100ml'),
(2, 'zalijevanje', '2025-12-20 10:30:00', 'Rijetko zalijevanje', '100ml'),
(2, 'zalijevanje', '2025-12-01 10:00:00', 'Rijetko zalijevanje', '100ml'),
(2, 'presađivanje', '2025-10-05 15:00:00', 'Presađena u veću posudu', NULL),
(2, 'zalijevanje', '2025-09-15 10:00:00', 'Zalijevanje prije presađivanja', '80ml'),

-- Bazilika događaji (ID=3)
(3, 'zalijevanje', '2026-01-17 08:00:00', 'Svakodnevno zalijevanje', '50ml'),
(3, 'zalijevanje', '2026-01-16 08:00:00', 'Svakodnevno zalijevanje', '50ml'),
(3, 'zalijevanje', '2026-01-15 08:00:00', 'Svakodnevno zalijevanje', '50ml'),
(3, 'zalijevanje', '2026-01-14 08:00:00', 'Svakodnevno zalijevanje', '50ml'),
(3, 'gnojenje', '2025-12-10 09:00:00', 'Organsko gnojivo', '3ml'),
(3, 'rezanje', '2025-12-05 12:00:00', 'Berba listova za pesto', NULL),
(3, 'gnojenje', '2025-11-10 09:00:00', 'Organsko gnojivo', '3ml'),
(3, 'zalijevanje', '2025-10-20 08:00:00', 'Zalijevanje', '50ml'),

-- Metvica događaji (ID=4)
(4, 'zalijevanje', '2026-01-16 09:00:00', 'Zalijevanje', '200ml'),
(4, 'zalijevanje', '2026-01-09 09:00:00', 'Zalijevanje', '200ml'),
(4, 'zalijevanje', '2026-01-02 09:00:00', 'Zalijevanje', '200ml'),
(4, 'zalijevanje', '2025-12-26 09:00:00', 'Zalijevanje', '200ml'),
(4, 'rezanje', '2025-11-20 14:00:00', 'Berba za čaj', NULL),

-- Orhideja događaji (ID=5)
(5, 'zalijevanje', '2026-01-12 10:00:00', 'Potapanje u vodu 15 min', NULL),
(5, 'zalijevanje', '2026-01-05 10:00:00', 'Potapanje u vodu 15 min', NULL),
(5, 'zalijevanje', '2025-12-29 10:00:00', 'Potapanje u vodu 15 min', NULL),
(5, 'zalijevanje', '2025-12-22 10:00:00', 'Potapanje u vodu 15 min', NULL),
(5, 'napomena', '2025-11-20 16:00:00', 'Zadnji cvijet je uveo', NULL);

-- ============================================
-- PODSJETNICI
-- ============================================

INSERT INTO reminders (plant_id, reminder_type, frequency, last_performed, next_due, is_active) VALUES
(1, 'zalijevanje', 'tjedno', '2026-01-15 09:00:00', '2026-01-22 09:00:00', TRUE),
(1, 'gnojenje', 'mjesečno', '2025-12-01 11:00:00', '2026-01-01 11:00:00', TRUE),
(2, 'zalijevanje', 'dvotjedno', '2026-01-10 10:00:00', '2026-01-24 10:00:00', TRUE),
(3, 'zalijevanje', 'dnevno', '2026-01-17 08:00:00', '2026-01-18 08:00:00', TRUE),
(4, 'zalijevanje', 'tjedno', '2026-01-16 09:00:00', '2026-01-23 09:00:00', TRUE),
(5, 'zalijevanje', 'tjedno', '2026-01-12 10:00:00', '2026-01-19 10:00:00', TRUE);

-- ============================================
-- MJERENJA RASTA
-- ============================================

-- Monstera rast (ID=1)
INSERT INTO growth_measurements (plant_id, height_cm, width_cm, leaf_count, measurement_date, notes) VALUES
(1, 45.0, 40.0, 8, '2025-03-20 12:00:00', 'Početno mjerenje'),
(1, 52.0, 45.0, 10, '2025-05-15 12:00:00', 'Dva nova lista'),
(1, 61.0, 52.0, 12, '2025-07-10 12:00:00', 'Odličan rast'),
(1, 68.0, 58.0, 14, '2025-09-05 12:00:00', 'Stabilan rast'),
(1, 73.0, 62.0, 15, '2025-11-01 12:00:00', 'Kasna jesen'),
(1, 75.0, 63.0, 16, '2026-01-10 12:00:00', 'Zima - sporiji rast'),

-- Bazilika rast (ID=3)
(3, 5.0, 3.0, 6, '2025-08-08 10:00:00', 'Nicanje'),
(3, 12.0, 8.0, 18, '2025-09-01 10:00:00', 'Brzi rast'),
(3, 22.0, 15.0, 32, '2025-10-15 10:00:00', 'Bujna biljka'),
(3, 28.0, 18.0, 28, '2025-11-20 10:00:00', 'Nakon nekoliko berbi'),
(3, 25.0, 20.0, 35, '2026-01-05 10:00:00', 'Cijela i zdrava'),

-- Aloe Vera rast (ID=2)
(2, 15.0, 12.0, 8, '2025-06-01 11:00:00', 'Početno mjerenje'),
(2, 18.0, 15.0, 10, '2025-08-15 11:00:00', 'Spor ali stabilan rast'),
(2, 20.0, 17.0, 12, '2025-11-01 11:00:00', 'Prije presađivanja'),
(2, 22.0, 18.0, 13, '2026-01-08 11:00:00', 'Nakon presađivanja');

-- ============================================
-- SLIKE (putanje do datoteka)
-- ============================================

INSERT INTO images (plant_id, file_path, caption, taken_at) VALUES
(1, '/static/uploads/plant_image.jpg', 'Monstera nakon kupnje', '2025-03-20 13:00:00'),
(1, '/static/uploads/plant_image.jpg', 'Monstera s novim listovima', '2025-07-10 14:00:00'),
(1, '/static/uploads/plant_image.jpg', 'Monstera u jesen', '2025-11-01 11:00:00'),
(1, '/static/uploads/plant_image.jpg', 'Aktualna Monstera', '2026-01-10 10:00:00'),

(2, '/static/uploads/plant_image.jpg', 'Aloe nakon nabave', '2025-05-20 12:00:00'),
(2, '//static/uploads/plant_image.jpg', 'Aloe nakon presađivanja', '2025-10-05 16:00:00'),

(3, '/static/uploads/plant_image.jpg', 'Bazilika u punom cvatu', '2025-10-15 12:00:00'),
(3, '/static/uploads/plant_image.jpg', 'Bazilika početkom godine', '2026-01-05 10:00:00'),

(4, '/static/uploads/plant_image.jpg', 'Metvica nakon sadnje', '2025-06-10 14:00:00'),
(4, '/static/uploads/plant_image.jpg', 'Metvica prije berbe', '2025-11-20 13:00:00'),

(5, '/static/uploads/plant_image.jpg', 'Orhideja - poklon', '2025-04-14 10:00:00'),
(5, '/static/uploads/plant_image.jpg', 'Orhideja u cvatnji', '2025-06-20 11:00:00'),
(5, '/static/uploads/plant_image.jpg', 'Orhideja nakon cvatnje', '2025-11-20 16:30:00');

-- ============================================
-- TESTIRANJE TEMPORALNIH UPITA
-- ============================================

-- Simulacija promjena statusa kroz vrijeme
UPDATE plants SET current_status = 'bolesna' WHERE plant_id = 5;
UPDATE plants SET current_status = 'mirovanje' WHERE plant_id = 5;

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
    RAISE NOTICE 'Datum posljednjeg ažuriranja: 2026-01-18';
    RAISE NOTICE '====================================';
END $$;

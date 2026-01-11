-- ============================================
-- PlantTracker - Primjeri SQL upita
-- Demonstracija aktivnih i temporalnih baza
-- ============================================

-- ============================================
-- TEMPORALNI UPITI
-- ============================================

-- 1. Dohvati status biljke na određeni datum
-- Pitanje: Kakav je bio status Monstera 1. lipnja 2024?
SELECT get_plant_status_at(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::UUID,
    '2024-06-01 00:00:00'::TIMESTAMP
) AS status_1_lipnja;

-- 2. Dohvati kompletnu povijest statusa za biljku
SELECT 
    status,
    valid_from,
    valid_to,
    COALESCE(valid_to, CURRENT_TIMESTAMP) - valid_from AS duration
FROM plant_status_history
WHERE plant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
ORDER BY valid_from;

-- 3. Dohvati sve biljke koje su bile bolesne u zadnjih 30 dana
SELECT DISTINCT 
    p.common_name,
    psh.status,
    psh.valid_from,
    psh.valid_to
FROM plants p
JOIN plant_status_history psh ON p.plant_id = psh.plant_id
WHERE psh.status = 'bolesna'
  AND psh.valid_from >= CURRENT_TIMESTAMP - INTERVAL '30 days';

-- 4. Koliko dugo je svaka biljka bila u određenom statusu?
SELECT 
    p.common_name,
    psh.status,
    SUM(COALESCE(psh.valid_to, CURRENT_TIMESTAMP) - psh.valid_from) AS total_duration
FROM plants p
JOIN plant_status_history psh ON p.plant_id = psh.plant_id
GROUP BY p.common_name, psh.status
ORDER BY p.common_name, total_duration DESC;

-- 5. Trend rasta - visina biljke kroz vrijeme
SELECT * FROM get_growth_trend(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::UUID,
    180 -- zadnjih 180 dana
);

-- 6. Prosječna stopa rasta po mjesecima
SELECT 
    p.common_name,
    DATE_TRUNC('month', gm.measurement_date) AS month,
    AVG(gm.height_cm - LAG(gm.height_cm) OVER (
        PARTITION BY gm.plant_id 
        ORDER BY gm.measurement_date
    )) AS avg_monthly_growth
FROM plants p
JOIN growth_measurements gm ON p.plant_id = gm.plant_id
GROUP BY p.common_name, month
ORDER BY p.common_name, month;

-- ============================================
-- UPITI VEZANI ZA AKTIVNE BAZE (Triggers)
-- ============================================

-- 7. Prikaz svih dospjelih podsjetnika (VIEW koristi aktivne podatke)
SELECT * FROM overdue_reminders;

-- 8. Dodavanje događaja zalijevanja - AKTIVIRA TRIGGER!
-- Ovaj INSERT će automatski:
-- - Ažurirati reminder
-- - Izračunati sljedeći datum
-- - Označiti notifikacije kao pročitane
INSERT INTO events (plant_id, event_type, description, amount)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'zalijevanje',
    'Zalijevanje nakon testiranja',
    '250ml'
);

-- 9. Provjera automatskog ažuriranja podsjetnika nakon događaja
SELECT 
    r.reminder_type,
    r.frequency,
    r.last_performed,
    r.next_due,
    r.next_due - CURRENT_TIMESTAMP AS time_until_next
FROM reminders r
WHERE r.plant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
  AND r.reminder_type = 'zalijevanje';

-- 10. Prikaz automatski generiranih notifikacija
SELECT 
    n.notification_id,
    n.message,
    n.created_at,
    n.is_read,
    p.common_name
FROM notifications n
JOIN plants p ON n.plant_id = p.plant_id
WHERE n.created_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
ORDER BY n.created_at DESC;

-- 11. Testiranje promjene statusa - AKTIVIRA TRIGGER ZA TEMPORALNU POVIJEST!
-- Ovaj UPDATE će automatski kreirati zapis u plant_status_history
UPDATE plants 
SET current_status = 'cvatnja'
WHERE plant_id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';

-- Provjera temporalne povijesti nakon promjene
SELECT * FROM plant_status_history
WHERE plant_id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'
ORDER BY valid_from DESC;

-- ============================================
-- ANALITIČKI UPITI
-- ============================================

-- 12. Prosječan interval zalijevanja po biljci
SELECT 
    p.common_name,
    calculate_avg_watering_interval(p.plant_id) AS avg_interval,
    COUNT(e.event_id) AS total_waterings
FROM plants p
LEFT JOIN events e ON p.plant_id = e.plant_id AND e.event_type = 'zalijevanje'
GROUP BY p.plant_id, p.common_name
ORDER BY avg_interval;

-- 13. Najaktivniji dani u tjednu za održavanje
SELECT 
    TO_CHAR(event_date, 'Day') AS day_of_week,
    event_type,
    COUNT(*) AS event_count
FROM events
GROUP BY day_of_week, event_type
ORDER BY event_count DESC;

-- 14. Biljke koje trebaju najviše pažnje
SELECT 
    p.common_name,
    p.current_status,
    COUNT(DISTINCT e.event_id) AS total_events,
    MAX(e.event_date) AS last_activity,
    CURRENT_TIMESTAMP - MAX(e.event_date) AS days_inactive,
    COUNT(DISTINCT CASE WHEN e.event_type = 'bolest' THEN e.event_id END) AS disease_count
FROM plants p
LEFT JOIN events e ON p.plant_id = e.plant_id
GROUP BY p.plant_id, p.common_name, p.current_status
HAVING CURRENT_TIMESTAMP - MAX(e.event_date) > INTERVAL '7 days'
    OR COUNT(DISTINCT CASE WHEN e.event_type = 'bolest' THEN e.event_id END) > 0
ORDER BY days_inactive DESC, disease_count DESC;

-- 15. Mjesečni izvještaj aktivnosti
SELECT 
    DATE_TRUNC('month', event_date) AS month,
    event_type,
    COUNT(*) AS count,
    ROUND(AVG(CASE 
        WHEN event_type = 'zalijevanje' 
        THEN EXTRACT(EPOCH FROM (event_date - LAG(event_date) OVER (
            PARTITION BY plant_id, event_type 
            ORDER BY event_date
        ))) / 86400
    END), 2) AS avg_days_between
FROM events
WHERE event_date >= CURRENT_TIMESTAMP - INTERVAL '6 months'
GROUP BY month, event_type
ORDER BY month DESC, count DESC;

-- ============================================
-- KOMPLEKSNI TEMPORALNI UPITI
-- ============================================

-- 16. Kako se mijenjao status biljaka kroz vrijeme?
SELECT 
    p.common_name,
    psh.status,
    COUNT(*) AS times_in_status,
    SUM(COALESCE(psh.valid_to, CURRENT_TIMESTAMP) - psh.valid_from) AS total_time,
    ROUND(
        100.0 * SUM(COALESCE(psh.valid_to, CURRENT_TIMESTAMP) - psh.valid_from) / 
        SUM(SUM(COALESCE(psh.valid_to, CURRENT_TIMESTAMP) - psh.valid_from)) OVER (PARTITION BY p.plant_id),
        2
    ) AS percentage
FROM plants p
JOIN plant_status_history psh ON p.plant_id = psh.plant_id
GROUP BY p.plant_id, p.common_name, psh.status
ORDER BY p.common_name, total_time DESC;

-- 17. Point-in-time analiza - stanje svih biljaka na određeni datum
WITH target_date AS (
    SELECT '2024-09-01 00:00:00'::TIMESTAMP AS t
)
SELECT 
    p.common_name,
    get_plant_status_at(p.plant_id, (SELECT t FROM target_date)) AS status_on_date,
    (SELECT COUNT(*) 
     FROM events e 
     WHERE e.plant_id = p.plant_id 
       AND e.event_date <= (SELECT t FROM target_date)
    ) AS events_until_date
FROM plants p;

-- ============================================
-- FUNKCIJE ZA IZVJEŠTAJE
-- ============================================

-- 18. Generiranje kompletnog izvještaja za biljku
SELECT * FROM generate_plant_report('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');

-- 19. Pregled svih biljaka s upozorenjima
SELECT * FROM get_plants_overview()
WHERE needs_attention = TRUE;

-- 20. Statistika rasta
SELECT * FROM get_growth_statistics('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');

-- ============================================
-- DEMONSTRACIJA STORED PROCEDURE
-- ============================================

-- 21. Kreiranje pametnog podsjetnika
CALL create_smart_watering_reminder('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13');

-- 22. Arhiviranje starih podataka
CALL archive_old_data(365); -- Arhiviraj podatke starije od godine dana

-- ============================================
-- PERFORMANCE TESTOVI
-- ============================================

-- 23. Testiranje GiST indeksa za temporalne upite
EXPLAIN ANALYZE
SELECT * FROM plant_status_history
WHERE plant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
  AND tsrange(valid_from, valid_to) @> '2024-06-15 12:00:00'::TIMESTAMP;

-- 24. Provjera efikasnosti indeksa na događajima
EXPLAIN ANALYZE
SELECT * FROM events
WHERE plant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
  AND event_type = 'zalijevanje'
ORDER BY event_date DESC
LIMIT 10;

-- ============================================
-- NAPOMENE
-- ============================================

-- Ovi upiti demonstriraju:
-- 1. Temporalne mogućnosti PostgreSQL-a (valid time queries)
-- 2. Aktivne baze kroz automatske trigger-e
-- 3. Kompleksne analitičke upite
-- 4. Stored procedures i funkcije
-- 5. Optimizaciju kroz indekse

-- Za detaljnije primjere, pogledaj dokumentaciju i aplikacijski kod.

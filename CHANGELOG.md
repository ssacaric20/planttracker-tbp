# Changelog

Sve značajne promjene u projektu PlantTracker bit će dokumentirane u ovoj datoteci.

### Dodano
- Inicijalna verzija PlantTracker aplikacije
- PostgreSQL baza podataka s aktivnim i temporalnim značajkama
- Tablica `plants` za osnovne informacije o biljkama
- Temporalna tablica `plant_status_history` za praćenje povijesti statusa
- Tablica `events` za evidentiranje svih aktivnosti (zalijevanje, gnojenje, itd.)
- Tablica `reminders` za automatske podsjetnika
- Tablica `notifications` za notifikacije generirane okidačima
- Tablica `growth_measurements` za praćenje rasta kroz vrijeme
- Tablica `images` za pohranu slika biljaka

### Okidači (Triggers)
- `trigger_update_plant_timestamp` - Automatsko ažuriranje updated_at polja
- `trigger_track_status_change` - Automatsko evidentiranje promjena statusa
- `trigger_initialize_status` - Inicijalizacija povijesti za nove biljke
- `trigger_generate_notifications` - Generiranje notifikacija iz podsjetnika
- `trigger_update_reminder` - Automatsko ažuriranje podsjetnika nakon događaja
- `trigger_check_watering` - Upozorenje na neobično duge intervale bez zalijevanja

### Funkcije
- `get_plant_status_at()` - Dohvaćanje statusa u određenom trenutku
- `get_status_history()` - Dohvaćanje povijesti statusa u vremenskom razdoblju
- `calculate_avg_watering_interval()` - Prosječni interval zalijevanja
- `get_growth_statistics()` - Statistika rasta biljke
- `get_growth_trend()` - Trend rasta u zadnjih N dana
- `generate_plant_report()` - Generiranje detaljnog izvještaja
- `get_plants_overview()` - Pregled svih biljaka

### Stored Procedures
- `create_smart_watering_reminder()` - Kreiranje pametnog podsjetnika
- `archive_old_data()` - Arhiviranje starih podataka

### Pogledi (Views)
- `overdue_reminders` - Dospjeli podsjetnici
- `current_plant_status` - Trenutni status svih biljaka
- `plant_event_stats` - Statistika događaja po biljci

### Aplikacija
- Flask web aplikacija
- REST API endpoints
- Grafičko sučelje za pregled biljaka
- Sustav autentifikacije (osnovna verzija)

### Dokumentacija
- Kompletna LaTeX dokumentacija
- README s uputama za instalaciju
- SQL primjeri upita
- Tehnička dokumentacija API-ja

### Infrastruktura
- Automatska instalacijska skripta (`install.sh`)

# PlantTracker - Aplikacija za praćenje rasta biljaka

Aplikacija za praćenje i pomoć u održavanju rasta biljaka s podrškom za temporalno praćenje, automatske podsjetnika i vizualno dokumentiranje.

## Značajke

- **Upravljanje biljkama**: Evidencija biljaka s detaljnim informacijama
- **Temporalno praćenje**: Praćenje povijesti rasta i promjena stanja kroz vrijeme
- **Aktivni podsjetnici**: Automatski okidači za zalijevanje, gnojenje i druge aktivnosti
- **Galerija slika**: Vizualno dokumentiranje rasta biljaka
- **Analitika**: Statistike i trendovi rasta

## Tehnologije

- **Baza podataka**: PostgreSQL (aktivne i temporalne baze)
- **Backend**: Python Flask
- **Frontend**: HTML/CSS/JavaScript
- **Verzioniranje**: Git

## Instalacija

### Preduvjeti
- PostgreSQL 12+
- Python 3.8+
- pip

### Automatska instalacija

```bash
chmod +x install.sh
./install.sh
```

### Ručna instalacija

1. Kreiraj PostgreSQL bazu podataka:
```bash
createdb planttracker
```

2. Izvedi SQL skripte:
```bash
psql -d planttracker -f database/01_schema.sql
psql -d planttracker -f database/02_triggers.sql
psql -d planttracker -f database/03_functions.sql
psql -d planttracker -f database/04_sample_data.sql
```

3. Instaliraj Python dependencies:
```bash
pip install -r requirements.txt
```

4. Pokreni aplikaciju:
```bash
cd application
python app.py
```

5. Otvori preglednik na `http://localhost:5000`

## Dokumentacija

Detaljnu dokumentaciju možeš naći u direktoriju `documentation/`.

## 📄 Licenca

GNU General Public License v3.0

## Sandra Sačarić

Projekt izrađen za kolegij Teorija Baza Podataka

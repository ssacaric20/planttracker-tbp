# PlantTracker - Aplikacija za praćenje rasta biljaka

Aplikacija za praćenje i pomoć u održavanju rasta biljaka s podrškom za temporalno praćenje, automatske podsjetnika i vizualno dokumentiranje.

## Značajke

- **Upravljanje biljkama**: evidencija biljaka s detaljnim informacijama
- **Temporalno praćenje**: praćenje povijesti rasta i promjena stanja kroz vrijeme
- **Aktivni podsjetnici**: automatski okidači za zalijevanje, gnojenje i druge aktivnosti
- **Galerija slika**: vizualno dokumentiranje rasta biljaka
- **Analitika**: statistike i trendovi rasta

## Tehnologije

- **Baza podataka**: PostgreSQL (aktivne i temporalne baze)
- **Backend**: Python Flask
- **Frontend**: HTML, inline CSS
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

1. Kreiranje PostgreSQL baze podataka:
```bash
createdb planttracker
```

2. SQL skripte:
```bash
psql -d planttracker -f database/01_schema.sql
psql -d planttracker -f database/02_triggers.sql
psql -d planttracker -f database/03_functions.sql
psql -d planttracker -f database/04_sample_data.sql
```

3. Python dependencies:
```bash
pip install -r requirements.txt
```

4. Pokretanje aplikacije:
```bash
cd application
python app.py
```

5. Preglednik na `http://localhost:5000`

## Dokumentacija

Detaljna dokumentacija u direktoriju `documentation/`.

## 📄 Licenca

GNU General Public License v3.0

## Sandra Sačarić

Projekt izrađen za kolegij Teorija Baza Podataka

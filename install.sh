#!/bin/bash

# ============================================
# PlantTracker skripta
# Automatska instalacija baze podataka i aplikacije
# ============================================

set -e  # Zaustavi izvršavanje kod greške

echo "======================================"
echo "PlantTracker - Instalacijska skripta"
echo "======================================"
echo ""

# Boje za output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Provjera PostgreSQL instalacije
echo -e "${YELLOW}[1/7] Provjera PostgreSQL instalacije...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${RED}PostgreSQL nije instaliran!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL je instaliran${NC}"
echo ""

# Provjera Python instalacije
echo -e "${YELLOW}[2/7] Provjera Python instalacije...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 nije instaliran!${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✓ $PYTHON_VERSION je instaliran${NC}"
echo ""

# Konfiguracija baze podataka
DB_NAME="planttracker"
DB_USER="planttracker"
DB_PASSWORD="pass123"  # password - može se mijenjati
DB_HOST="localhost"
DB_PORT="5432"

# Provjera postojeće baze
echo -e "${YELLOW}[3/7] Provjera postojeće baze podataka...${NC}"
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo -e "${YELLOW}Baza podataka '$DB_NAME' već postoji.${NC}"
    read -p "Želite li je izbrisati i ponovno stvoriti? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Brisanje postojeće baze..."
        sudo -u postgres dropdb $DB_NAME 2>/dev/null || true
    else
        echo -e "${RED}Instalacija prekinuta.${NC}"
        exit 1
    fi
fi

# Kreiranje database korisnika
echo -e "${YELLOW}[4/7] Kreiranje database korisnika...${NC}"

# Provjeri postoji li korisnik
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
    echo "Korisnik '$DB_USER' već postoji, preskačem kreiranje..."
else
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
    echo -e "${GREEN}✓ Korisnik '$DB_USER' kreiran${NC}"
fi
echo ""

# Kreiranje baze podataka
echo -e "${YELLOW}[5/7] Kreiranje PostgreSQL baze podataka...${NC}"
sudo -u postgres createdb $DB_NAME
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
echo -e "${GREEN}✓ Baza podataka '$DB_NAME' kreirana${NC}"
echo ""

# Izvršavanje SQL skripti
echo -e "${YELLOW}[6/7] Izvršavanje SQL skripti...${NC}"

echo "  - Kreiranje sheme..."
sudo -u postgres psql -d $DB_NAME -f database/01_schema.sql > /dev/null
echo -e "${GREEN}  ✓ Shema kreirana${NC}"

echo "  - Kreiranje okidača..."
sudo -u postgres psql -d $DB_NAME -f database/02_triggers.sql > /dev/null
echo -e "${GREEN}  ✓ Okidači kreirani${NC}"

echo "  - Kreiranje funkcija..."
sudo -u postgres psql -d $DB_NAME -f database/03_functions.sql > /dev/null
echo -e "${GREEN}  ✓ Funkcije kreirane${NC}"

echo "  - Učitavanje primjera podataka..."
sudo -u postgres psql -d $DB_NAME -f database/04_sample_data.sql > /dev/null
echo -e "${GREEN}  ✓ Primjeri podataka učitani${NC}"

# Daj pristup korisniku na sve tablice
echo "  - Postavljanje dozvola..."
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;"
echo -e "${GREEN}  ✓ Dozvole postavljene${NC}"
echo ""

# Instalacija Python zavisnosti
echo -e "${YELLOW}[7/7] Instaliranje Python paketa...${NC}"
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt --quiet --break-system-packages 2>/dev/null || pip3 install -r requirements.txt --quiet
    echo -e "${GREEN}✓ Python paketi instalirani${NC}"
else
    echo -e "${YELLOW}⚠  requirements.txt nije pronađen, preskačem instalaciju paketa${NC}"
fi
echo ""

# Kreiranje .env datoteke za konfiguraciju
echo -e "${YELLOW}Kreiranje konfiguracijske datoteke...${NC}"
cat > application/.env <<ENVEOF
# Database Configuration
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT

# Application Configuration
FLASK_APP=app.py
FLASK_ENV=development
SECRET_KEY=$(openssl rand -hex 32)
UPLOAD_FOLDER=static/uploads
ENVEOF
echo -e "${GREEN}✓ Konfiguracijska datoteka kreirana${NC}"
echo ""

# Kreiranje direktorija za slike
mkdir -p application/static/uploads
mkdir -p application/templates

echo "======================================"
echo -e "${GREEN}✓ Instalacija uspješno završena!${NC}"
echo "======================================"
echo ""
echo "Za pokretanje aplikacije:"
echo "  cd application"
echo "  python3 app.py"
echo ""
echo "Aplikacija će biti dostupna na: http://localhost:5000"
echo ""
echo "Detalji baze podataka:"
echo "  Ime baze: $DB_NAME"
echo "  Korisnik: $DB_USER"
echo "  Lozinka: $DB_PASSWORD"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo ""
echo "Za spajanje na bazu:"
echo "  psql -U $DB_USER -d $DB_NAME -h $DB_HOST"
echo "  (lozinka: $DB_PASSWORD)"
echo ""
echo "Ili kao postgres korisnik:"
echo "  sudo -u postgres psql -d $DB_NAME"
echo ""

#!/bin/bash

# ============================================
# PlantTracker Installation Script
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
echo -e "${YELLOW}[1/6] Provjera PostgreSQL instalacije...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${RED}PostgreSQL nije instaliran!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL je instaliran${NC}"
echo ""

# Provjera Python instalacije
echo -e "${YELLOW}[2/6] Provjera Python instalacije...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 nije instaliran!${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✓ $PYTHON_VERSION je instaliran${NC}"
echo ""

# Konfiguracija baze podataka
DB_NAME="planttracker"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# Provjera postoji li baza
echo -e "${YELLOW}[3/6] Provjera postojeće baze podataka...${NC}"
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

# Kreiranje baze podataka
echo -e "${YELLOW}[4/6] Kreiranje PostgreSQL baze podataka...${NC}"
sudo -u postgres createdb $DB_NAME
echo -e "${GREEN}✓ Baza podataka '$DB_NAME' kreirana${NC}"
echo ""

# Izvršavanje SQL skripti
echo -e "${YELLOW}[5/6] Izvršavanje SQL skripti...${NC}"

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
echo ""

# Instalacija Python zavisnosti
echo -e "${YELLOW}[6/6] Instaliranje Python paketa...${NC}"
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt --quiet --break-system-packages 2>/dev/null || pip3 install -r requirements.txt --quiet
    echo -e "${GREEN}✓ Python paketi instalirani${NC}"
else
    echo -e "${YELLOW}⚠ requirements.txt nije pronađen, preskačem instalaciju paketa${NC}"
fi
echo ""

# Kreiranje .env datoteke za konfiguraciju
echo -e "${YELLOW}Kreiranje konfiguracijske datoteke...${NC}"
cat > application/.env <<ENVEOF
# Database Configuration
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_PASSWORD=

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
mkdir -p application/static/css
mkdir -p application/static/js
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
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo ""
echo "Za spajanje na bazu:"
echo "  sudo -u postgres psql -d $DB_NAME"
echo ""

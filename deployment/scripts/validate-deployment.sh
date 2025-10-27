#!/bin/bash
# Script de validation des fichiers de déploiement
# Ce script vérifie que tous les fichiers créés sont valides

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Validation des Fichiers de Déploiement            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0

# Fonction pour vérifier l'existence d'un fichier
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1 - MANQUANT${NC}"
        ((ERRORS++))
    fi
}

# Fonction pour vérifier qu'un fichier est exécutable
check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✅ $1 (exécutable)${NC}"
    else
        echo -e "${RED}❌ $1 - PAS EXÉCUTABLE${NC}"
        ((ERRORS++))
    fi
}

# Fonction pour vérifier la syntaxe bash
check_bash_syntax() {
    if bash -n "$1" 2>/dev/null; then
        echo -e "${GREEN}✅ $1 (syntaxe bash OK)${NC}"
    else
        echo -e "${RED}❌ $1 - ERREUR DE SYNTAXE BASH${NC}"
        bash -n "$1"
        ((ERRORS++))
    fi
}

echo -e "${YELLOW}Vérification des fichiers de configuration...${NC}"
check_file "deployment/nginx/borneez.conf"
check_file "deployment/nginx/Caddyfile"

echo ""
echo -e "${YELLOW}Vérification des services systemd...${NC}"
check_file "deployment/systemd/borneez-gpio.service"
check_file "deployment/systemd/borneez-server.service"

echo ""
echo -e "${YELLOW}Vérification des scripts...${NC}"
check_file "deployment/scripts/setup-production.sh"
check_executable "deployment/scripts/setup-production.sh"
check_bash_syntax "deployment/scripts/setup-production.sh"

check_file "start-production.sh"
check_executable "start-production.sh"
check_bash_syntax "start-production.sh"

echo ""
echo -e "${YELLOW}Vérification de la documentation...${NC}"
check_file "deployment/README.md"
check_file "deployment/ARCHITECTURE.md"
check_file "deployment/CHANGELIST.md"
check_file "QUICKSTART_PRODUCTION.md"

echo ""
echo -e "${YELLOW}Vérification des fichiers de base...${NC}"
check_file "README.md"
check_file "DEPLOYMENT.md"
check_file "package.json"
check_file "BGPIO.py"
check_file "BGPIO_mock.py"

echo ""
echo -e "${YELLOW}Vérification de la structure du projet...${NC}"
if [ -d "deployment" ]; then
    echo -e "${GREEN}✅ Répertoire deployment/ existe${NC}"
else
    echo -e "${RED}❌ Répertoire deployment/ manquant${NC}"
    ((ERRORS++))
fi

if [ -d "deployment/nginx" ]; then
    echo -e "${GREEN}✅ Répertoire deployment/nginx/ existe${NC}"
else
    echo -e "${RED}❌ Répertoire deployment/nginx/ manquant${NC}"
    ((ERRORS++))
fi

if [ -d "deployment/systemd" ]; then
    echo -e "${GREEN}✅ Répertoire deployment/systemd/ existe${NC}"
else
    echo -e "${RED}❌ Répertoire deployment/systemd/ manquant${NC}"
    ((ERRORS++))
fi

if [ -d "deployment/scripts" ]; then
    echo -e "${GREEN}✅ Répertoire deployment/scripts/ existe${NC}"
else
    echo -e "${RED}❌ Répertoire deployment/scripts/ manquant${NC}"
    ((ERRORS++))
fi

echo ""
echo -e "${YELLOW}Vérification de la syntaxe des fichiers de service systemd...${NC}"

# Vérifier que les fichiers service ont le bon format
for service in deployment/systemd/*.service; do
    if grep -q "^\[Unit\]" "$service" && \
       grep -q "^\[Service\]" "$service" && \
       grep -q "^\[Install\]" "$service"; then
        echo -e "${GREEN}✅ $service (format systemd OK)${NC}"
    else
        echo -e "${RED}❌ $service - FORMAT SYSTEMD INVALIDE${NC}"
        ((ERRORS++))
    fi
done

echo ""
echo -e "${YELLOW}Vérification de la configuration Nginx...${NC}"
if grep -q "listen 80" deployment/nginx/borneez.conf && \
   grep -q "proxy_pass" deployment/nginx/borneez.conf; then
    echo -e "${GREEN}✅ deployment/nginx/borneez.conf (format nginx OK)${NC}"
else
    echo -e "${RED}❌ deployment/nginx/borneez.conf - FORMAT NGINX INVALIDE${NC}"
    ((ERRORS++))
fi

echo ""
echo -e "${YELLOW}Vérification de la configuration Caddy...${NC}"
if grep -q "reverse_proxy" deployment/nginx/Caddyfile; then
    echo -e "${GREEN}✅ deployment/nginx/Caddyfile (format caddy OK)${NC}"
else
    echo -e "${RED}❌ deployment/nginx/Caddyfile - FORMAT CADDY INVALIDE${NC}"
    ((ERRORS++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les tests ont réussi! ${NC}"
    echo -e "${GREEN}✨ Les fichiers de déploiement sont prêts à l'emploi. ✨${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS erreur(s) détectée(s)${NC}"
    echo -e "${RED}Veuillez corriger les erreurs avant de déployer.${NC}"
    exit 1
fi

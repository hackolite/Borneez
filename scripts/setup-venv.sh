#!/bin/bash

# Script pour créer et configurer l'environnement virtuel Python
# Ce script configure un environnement virtuel pour isoler les dépendances Python

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VENV_DIR="$PROJECT_DIR/venv"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🐍 Configuration de l'environnement virtuel Python    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier que Python3 est installé
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 n'est pas installé!${NC}"
    echo "Installez Python3 avec: sudo apt-get install python3 python3-venv python3-pip"
    exit 1
fi

echo -e "${GREEN}✅ Python3 trouvé: $(python3 --version)${NC}"

# Créer le répertoire venv s'il n'existe pas
if [ -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}⚠️  L'environnement virtuel existe déjà dans: $VENV_DIR${NC}"
    read -p "Voulez-vous le recréer? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️  Suppression de l'ancien environnement...${NC}"
        rm -rf "$VENV_DIR"
    else
        echo -e "${YELLOW}⏭️  Utilisation de l'environnement existant...${NC}"
    fi
fi

# Créer l'environnement virtuel si nécessaire
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}📦 Création de l'environnement virtuel...${NC}"
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Échec de la création de l'environnement virtuel${NC}"
        echo "Installez python3-venv avec: sudo apt-get install python3-venv"
        exit 1
    fi
    echo -e "${GREEN}✅ Environnement virtuel créé${NC}"
fi

# Activer l'environnement virtuel
echo -e "${YELLOW}🔧 Activation de l'environnement virtuel...${NC}"
source "$VENV_DIR/bin/activate"

# Mettre à jour pip
echo -e "${YELLOW}⬆️  Mise à jour de pip...${NC}"
pip install --upgrade pip -q

# Installer les dépendances depuis requirements.txt
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    echo -e "${YELLOW}📦 Installation des dépendances depuis requirements.txt...${NC}"
    pip install -r "$PROJECT_DIR/requirements.txt" -q
    echo -e "${GREEN}✅ Dépendances installées${NC}"
else
    echo -e "${YELLOW}⚠️  Fichier requirements.txt non trouvé${NC}"
fi

# Vérifier si on est sur Raspberry Pi pour installer RPi.GPIO
if [ -f "/proc/device-tree/model" ] && grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo -e "${YELLOW}🍓 Raspberry Pi détecté${NC}"
    echo -e "${YELLOW}📦 Installation de RPi.GPIO (système)...${NC}"
    
    # RPi.GPIO doit être installé au niveau système pour accéder au matériel
    if ! python3 -c "import RPi.GPIO" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  RPi.GPIO n'est pas installé au niveau système${NC}"
        echo -e "${YELLOW}📋 Pour l'installer, exécutez:${NC}"
        echo -e "   ${BLUE}sudo apt-get update${NC}"
        echo -e "   ${BLUE}sudo apt-get install python3-rpi.gpio${NC}"
        echo ""
        echo -e "${YELLOW}Puis ajoutez un lien symbolique dans le venv:${NC}"
        SYSTEM_PACKAGES=$(python3 -c "import sys; print([p for p in sys.path if 'dist-packages' in p][0])")
        echo -e "   ${BLUE}ln -s $SYSTEM_PACKAGES/RPi $VENV_DIR/lib/python*/site-packages/${NC}"
    else
        # Créer un lien symbolique vers RPi.GPIO système
        SYSTEM_PACKAGES=$(python3 -c "import sys; print([p for p in sys.path if 'dist-packages' in p][0])" 2>/dev/null)
        VENV_SITE_PACKAGES=$(find "$VENV_DIR/lib" -type d -name "site-packages" | head -n 1)
        
        if [ -n "$SYSTEM_PACKAGES" ] && [ -n "$VENV_SITE_PACKAGES" ]; then
            if [ -d "$SYSTEM_PACKAGES/RPi" ] && [ ! -e "$VENV_SITE_PACKAGES/RPi" ]; then
                echo -e "${YELLOW}🔗 Création du lien symbolique vers RPi.GPIO...${NC}"
                ln -s "$SYSTEM_PACKAGES/RPi" "$VENV_SITE_PACKAGES/RPi" 2>/dev/null || true
                ln -s "$SYSTEM_PACKAGES/RPi.GPIO-"*.egg-info "$VENV_SITE_PACKAGES/" 2>/dev/null || true
            fi
        fi
        echo -e "${GREEN}✅ RPi.GPIO accessible depuis le venv${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Pas sur Raspberry Pi - RPi.GPIO non nécessaire${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✅ ENVIRONNEMENT CONFIGURÉ ✅                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📂 Emplacement: ${BLUE}$VENV_DIR${NC}"
echo ""
echo -e "${YELLOW}💡 Pour activer l'environnement manuellement:${NC}"
echo -e "   ${BLUE}source $VENV_DIR/bin/activate${NC}"
echo ""
echo -e "${YELLOW}💡 Pour désactiver l'environnement:${NC}"
echo -e "   ${BLUE}deactivate${NC}"
echo ""

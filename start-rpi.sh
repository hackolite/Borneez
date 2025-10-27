#!/bin/bash

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🚀 Borneez - Relay Control System 🚀            ║${NC}"
echo -e "${BLUE}║           Démarrage en mode RASPBERRY PI                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Fonction de nettoyage à la sortie
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt des services...${NC}"
    kill 0
    exit 0
}

trap cleanup SIGINT SIGTERM

# Vérifier si on est bien sur un Raspberry Pi
if [ ! -f "/proc/device-tree/model" ] || ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Attention: Ce script est conçu pour Raspberry Pi${NC}"
    echo -e "${YELLOW}   Utilisez 'start-dev.sh' pour le mode développement${NC}"
    read -p "Continuer quand même? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js n'est pas installé!${NC}"
    echo "Installez Node.js depuis https://nodejs.org/"
    exit 1
fi

# Vérifier si Python3 est installé
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 n'est pas installé!${NC}"
    exit 1
fi

# Installer les dépendances Node.js si nécessaire
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installation des dépendances Node.js...${NC}"
    npm install
fi

# Configurer l'environnement virtuel Python
VENV_DIR="./venv"
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}🐍 Configuration de l'environnement virtuel Python...${NC}"
    ./scripts/setup-venv.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erreur lors de la configuration de l'environnement virtuel${NC}"
        exit 1
    fi
fi

# Vérifier que le venv contient les dépendances nécessaires
echo -e "${YELLOW}🔍 Vérification des dépendances Python dans le venv...${NC}"
"$VENV_DIR/bin/python" -c "import fastapi, uvicorn, pydantic" 2>/dev/null
BASIC_DEPS=$?

if [ $BASIC_DEPS -ne 0 ]; then
    echo -e "${YELLOW}📦 Installation des dépendances Python dans le venv...${NC}"
    "$VENV_DIR/bin/pip" install -r requirements.txt -q
fi

# Vérifier RPi.GPIO (doit être installé au niveau système)
python3 -c "import RPi.GPIO" 2>/dev/null
GPIO_DEPS=$?

if [ $GPIO_DEPS -ne 0 ]; then
    echo -e "${YELLOW}📦 Installation de RPi.GPIO (système)...${NC}"
    # RPi.GPIO doit être installé via apt-get sur Raspberry Pi car il nécessite
    # des permissions système et un accès direct au matériel GPIO.
    # L'installation apt-get garantit la compilation correcte avec les en-têtes
    # kernel nécessaires et les bonnes permissions pour accéder à /dev/gpiomem
    sudo apt-get update
    sudo apt-get install -y python3-rpi.gpio
    
    # Créer un lien symbolique vers RPi.GPIO dans le venv
    SYSTEM_PACKAGES=$(python3 -c "import sys; print([p for p in sys.path if 'dist-packages' in p][0])" 2>/dev/null)
    VENV_SITE_PACKAGES=$(find "$VENV_DIR/lib" -type d -name "site-packages" | head -n 1)
    
    if [ -n "$SYSTEM_PACKAGES" ] && [ -n "$VENV_SITE_PACKAGES" ]; then
        ln -s "$SYSTEM_PACKAGES/RPi" "$VENV_SITE_PACKAGES/RPi" 2>/dev/null || true
        ln -s "$SYSTEM_PACKAGES/RPi.GPIO-"*.egg-info "$VENV_SITE_PACKAGES/" 2>/dev/null || true
    fi
fi

echo ""
echo -e "${GREEN}✅ Toutes les dépendances sont prêtes!${NC}"
echo ""

# Démarrer le backend GPIO (RÉEL) avec le venv
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}1️⃣  Démarrage du Backend GPIO (Mode Réel)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚡ Contrôle GPIO ACTIVÉ - Vérifiez votre câblage!${NC}"
"$VENV_DIR/bin/python" BGPIO.py &
BACKEND_PID=$!

# Attendre que le backend soit prêt
sleep 3

# Démarrer le frontend + proxy
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}2️⃣  Démarrage du Frontend + Proxy Server${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔐 Le port 80 nécessite les privilèges sudo...${NC}"
sudo PORT=80 npm run dev &
FRONTEND_PID=$!

# Attendre que le frontend soit prêt
sleep 5

# Obtenir l'IP locale et le hostname
LOCAL_IP=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ SYSTÈME DÉMARRÉ ✅                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Frontend disponible sur:${NC}"
echo -e "   Local:     ${BLUE}http://localhost${NC}"
echo -e "   Hostname:  ${BLUE}http://$HOSTNAME.local${NC}"
echo -e "   IP:        ${BLUE}http://$LOCAL_IP${NC}"
echo ""
echo -e "${GREEN}🔧 Backend GPIO sur:${NC}"
echo -e "   Local:  ${BLUE}http://localhost:8000${NC}"
echo -e "   Réseau: ${BLUE}http://$LOCAL_IP:8000${NC}"
echo ""
echo -e "${GREEN}📖 Documentation API:${NC}         ${BLUE}http://localhost:8000/docs${NC}"
echo ""
echo -e "${YELLOW}📝 Configuration requise (depuis un autre PC):${NC}"
echo -e "   1. Ouvrez ${BLUE}http://$HOSTNAME.local${NC} ou ${BLUE}http://$LOCAL_IP${NC}"
echo -e "   2. Cliquez sur 'API Configuration'"
echo -e "   3. Entrez l'endpoint: ${BLUE}http://$LOCAL_IP:8000${NC}"
echo -e "   4. Cliquez sur 'Test Connection' puis 'Save Configuration'"
echo ""
echo -e "${YELLOW}💡 Astuce: Pour activer l'accès via $HOSTNAME.local, installez:${NC}"
echo -e "   ${BLUE}sudo apt-get install avahi-daemon${NC}"
echo ""
echo -e "${RED}⚠️  Mode GPIO RÉEL - Les relais sont connectés!${NC}"
echo -e "${RED}⚠️  Appuyez sur Ctrl+C pour arrêter tous les services${NC}"
echo ""

# Attendre que les processus se terminent
wait

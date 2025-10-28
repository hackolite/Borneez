#!/bin/bash

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🚀 Borneez - Relay Control System 🚀            ║${NC}"
echo -e "${BLUE}║              Démarrage en mode DÉVELOPPEMENT             ║${NC}"
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

# Vérifier si les dépendances Python sont installées
echo -e "${YELLOW}🔍 Vérification des dépendances Python...${NC}"
python3 -c "import fastapi, uvicorn, pydantic" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}📦 Installation des dépendances Python...${NC}"
    pip3 install --break-system-packages fastapi uvicorn pydantic
fi

echo ""
echo -e "${GREEN}✅ Toutes les dépendances sont prêtes!${NC}"
echo ""

# Démarrer le backend GPIO
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}1️⃣  Démarrage du Backend GPIO${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
python3 BGPIO.py &
BACKEND_PID=$!

# Attendre que le backend soit prêt
sleep 3

# Démarrer le frontend + proxy
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}2️⃣  Démarrage du Frontend + Proxy Server${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
npm run dev &
FRONTEND_PID=$!

# Attendre que le frontend soit prêt
sleep 5

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ SYSTÈME DÉMARRÉ ✅                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Frontend disponible sur:${NC}    ${BLUE}http://localhost:5000${NC}"
echo -e "${GREEN}🔧 Backend GPIO sur:${NC}           ${BLUE}http://localhost:8000${NC}"
echo -e "${GREEN}📖 Documentation API:${NC}         ${BLUE}http://localhost:8000/docs${NC}"
echo ""
echo -e "${YELLOW}📝 Configuration requise:${NC}"
echo -e "   1. Ouvrez ${BLUE}http://localhost:5000${NC}"
echo -e "   2. Cliquez sur 'API Configuration'"
echo -e "   3. Entrez l'endpoint: ${BLUE}http://localhost:8000${NC}"
echo -e "   4. Cliquez sur 'Test Connection' puis 'Save Configuration'"
echo ""
echo -e "${RED}⚠️  Appuyez sur Ctrl+C pour arrêter tous les services${NC}"
echo ""

# Attendre que les processus se terminent
wait

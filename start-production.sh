#!/bin/bash

# Script de démarrage en production pour Borneez
# Ce script démarre l'application sur le port 80 (nécessite sudo)
# Usage: sudo ./start-production.sh

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🚀 Borneez - Production Mode (Port 80) 🚀        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier si on a les privilèges root pour le port 80
if [ "$PORT" = "80" ] && [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  Le port 80 nécessite les privilèges sudo${NC}"
    echo "Relancement avec sudo..."
    exec sudo PORT=80 "$0" "$@"
fi

# Vérifier que l'application est buildée
if [ ! -d "dist" ]; then
    echo -e "${YELLOW}📦 L'application n'est pas buildée. Lancement du build...${NC}"
    npm run build
fi

# Fonction de nettoyage à la sortie
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt des services...${NC}"
    kill 0
    exit 0
}

trap cleanup SIGINT SIGTERM

# Configurer l'environnement virtuel Python si nécessaire
VENV_DIR="./venv"
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}🐍 Configuration de l'environnement virtuel Python...${NC}"
    ./scripts/setup-venv.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erreur lors de la configuration de l'environnement virtuel${NC}"
        exit 1
    fi
fi

# Démarrer le backend GPIO (RÉEL) avec le venv
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}1️⃣  Démarrage du Backend GPIO (Mode Réel)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚡ Contrôle GPIO ACTIVÉ - Vérifiez votre câblage!${NC}"
"$VENV_DIR/bin/python" BGPIO.py &
BACKEND_PID=$!

# Attendre que le backend soit prêt
sleep 3

# Vérifier que le backend a bien démarré
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Erreur: Le backend GPIO n'a pas pu démarrer${NC}"
    exit 1
fi

# Démarrer le serveur en production
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}2️⃣  Démarrage du serveur en production${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Définir les variables d'environnement pour la production
export NODE_ENV=production
export PORT=${PORT:-80}
export RELAY_API_ENDPOINT=${RELAY_API_ENDPOINT:-http://localhost:8000}

echo -e "${GREEN}🔧 Configuration:${NC}"
echo -e "   NODE_ENV: ${BLUE}$NODE_ENV${NC}"
echo -e "   PORT: ${BLUE}$PORT${NC}"
echo -e "   RELAY_API_ENDPOINT: ${BLUE}$RELAY_API_ENDPOINT${NC}"
echo ""

# Démarrer le serveur
npm start &
SERVER_PID=$!

# Attendre que le serveur soit prêt
sleep 5

# Vérifier que le serveur a bien démarré
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo -e "${RED}❌ Erreur: Le serveur n'a pas pu démarrer${NC}"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Obtenir l'IP locale et le hostname
LOCAL_IP=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ SYSTÈME DÉMARRÉ EN PRODUCTION ✅          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Frontend disponible sur:${NC}"
if [ "$PORT" = "80" ]; then
    echo -e "   Local:     ${BLUE}http://localhost${NC}"
    echo -e "   Hostname:  ${BLUE}http://$HOSTNAME.local${NC}"
    echo -e "   IP:        ${BLUE}http://$LOCAL_IP${NC}"
else
    echo -e "   Local:     ${BLUE}http://localhost:$PORT${NC}"
    echo -e "   Hostname:  ${BLUE}http://$HOSTNAME.local:$PORT${NC}"
    echo -e "   IP:        ${BLUE}http://$LOCAL_IP:$PORT${NC}"
fi
echo ""
echo -e "${GREEN}🔧 Backend GPIO:${NC}"
echo -e "   Local:  ${BLUE}http://localhost:8000${NC}"
echo -e "   Réseau: ${BLUE}http://$LOCAL_IP:8000${NC}"
echo -e "   Docs:   ${BLUE}http://localhost:8000/docs${NC}"
echo ""
echo -e "${YELLOW}💡 Pour une installation permanente avec systemd:${NC}"
echo -e "   ${BLUE}sudo deployment/scripts/setup-production.sh${NC}"
echo ""
echo -e "${RED}⚠️  Mode GPIO RÉEL - Les relais sont connectés!${NC}"
echo -e "${RED}⚠️  Appuyez sur Ctrl+C pour arrêter tous les services${NC}"
echo ""

# Attendre que les processus se terminent
wait

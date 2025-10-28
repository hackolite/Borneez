#!/bin/bash

# Script d'installation et de déploiement pour Borneez en production
# Ce script configure le reverse proxy (Nginx ou Caddy) et les services systemd
# Usage: sudo ./setup-production.sh [nginx|caddy]

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Ce script doit être exécuté avec sudo${NC}"
    echo "Usage: sudo ./setup-production.sh [nginx|caddy]"
    exit 1
fi

# Récupérer l'utilisateur réel (celui qui a lancé sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo ~$REAL_USER)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          🚀 Borneez Production Setup Script 🚀           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📂 Répertoire du projet: ${PROJECT_DIR}${NC}"
echo -e "${GREEN}👤 Utilisateur: ${REAL_USER}${NC}"
echo ""

# Demander quel reverse proxy utiliser
PROXY_TYPE=${1:-}
if [ -z "$PROXY_TYPE" ]; then
    echo -e "${YELLOW}Quel reverse proxy souhaitez-vous installer?${NC}"
    echo "1) Nginx (recommandé pour la plupart des cas)"
    echo "2) Caddy (HTTPS automatique avec Let's Encrypt)"
    echo "3) Aucun (l'application tournera sur port 3000)"
    read -p "Votre choix (1-3): " choice
    case $choice in
        1) PROXY_TYPE="nginx" ;;
        2) PROXY_TYPE="caddy" ;;
        3) PROXY_TYPE="none" ;;
        *) echo -e "${RED}Choix invalide${NC}"; exit 1 ;;
    esac
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Étape 1: Installation des dépendances système${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Mise à jour des paquets
echo -e "${YELLOW}📦 Mise à jour des paquets...${NC}"
apt-get update -qq

# Installer Python et ses dépendances
echo -e "${YELLOW}🐍 Installation de Python et dépendances GPIO...${NC}"
apt-get install -y python3 python3-pip python3-rpi.gpio

# Installer les dépendances Python pour FastAPI
sudo -u $REAL_USER pip3 install --break-system-packages fastapi uvicorn pydantic

# Installer Node.js si nécessaire
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}📦 Installation de Node.js...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
else
    echo -e "${GREEN}✅ Node.js déjà installé ($(node --version))${NC}"
fi

# Installer mDNS pour accès via raspberrypi.local
if ! command -v avahi-daemon &> /dev/null; then
    echo -e "${YELLOW}📡 Installation d'Avahi (mDNS)...${NC}"
    apt-get install -y avahi-daemon avahi-utils
    systemctl enable avahi-daemon
    systemctl start avahi-daemon
else
    echo -e "${GREEN}✅ Avahi déjà installé${NC}"
fi

# Installer le reverse proxy choisi
if [ "$PROXY_TYPE" = "nginx" ]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Étape 2: Installation et configuration de Nginx${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    apt-get install -y nginx
    
    # Copier la configuration Nginx
    echo -e "${YELLOW}📝 Configuration de Nginx...${NC}"
    cp "$PROJECT_DIR/deployment/nginx/borneez.conf" /etc/nginx/sites-available/borneez
    
    # Créer le lien symbolique
    ln -sf /etc/nginx/sites-available/borneez /etc/nginx/sites-enabled/borneez
    
    # Supprimer la config par défaut si elle existe
    rm -f /etc/nginx/sites-enabled/default
    
    # Tester la configuration
    nginx -t
    
    # Redémarrer Nginx
    systemctl enable nginx
    systemctl restart nginx
    
    echo -e "${GREEN}✅ Nginx configuré et démarré${NC}"
    
elif [ "$PROXY_TYPE" = "caddy" ]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Étape 2: Installation et configuration de Caddy${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    # Installer Caddy
    apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt-get update -qq
    apt-get install -y caddy
    
    # Copier la configuration Caddy
    echo -e "${YELLOW}📝 Configuration de Caddy...${NC}"
    cp "$PROJECT_DIR/deployment/nginx/Caddyfile" /etc/caddy/Caddyfile
    
    # Créer le répertoire de logs
    mkdir -p /var/log/caddy
    chown caddy:caddy /var/log/caddy
    
    # Redémarrer Caddy
    systemctl enable caddy
    systemctl restart caddy
    
    echo -e "${GREEN}✅ Caddy configuré et démarré${NC}"
else
    echo -e "${YELLOW}⚠️  Aucun reverse proxy installé${NC}"
    echo -e "${YELLOW}L'application sera accessible sur le port 3000${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Étape 3: Build de l'application${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Se déplacer dans le répertoire du projet
cd "$PROJECT_DIR"

# Installer les dépendances Node.js
echo -e "${YELLOW}📦 Installation des dépendances Node.js...${NC}"
sudo -u $REAL_USER npm install

# Build de l'application
echo -e "${YELLOW}🔨 Build de l'application...${NC}"
sudo -u $REAL_USER npm run build

echo -e "${GREEN}✅ Application buildée${NC}"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Étape 4: Configuration des services systemd${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Adapter les chemins dans les fichiers service
echo -e "${YELLOW}📝 Configuration des services systemd...${NC}"

# Copier et adapter le service GPIO
sed "s|/home/pi/Borneez|$PROJECT_DIR|g" "$PROJECT_DIR/deployment/systemd/borneez-gpio.service" | \
sed "s|User=pi|User=$REAL_USER|g" | \
sed "s|Group=pi|Group=$REAL_USER|g" > /etc/systemd/system/borneez-gpio.service

# Copier et adapter le service serveur
# Si un reverse proxy est utilisé, le serveur reste sur port 3000
# Sinon, il utilise directement le port 80
if [ "$PROXY_TYPE" = "none" ]; then
    SERVER_PORT=80
else
    SERVER_PORT=3000
fi

sed "s|/home/pi/Borneez|$PROJECT_DIR|g" "$PROJECT_DIR/deployment/systemd/borneez-server.service" | \
sed "s|User=pi|User=$REAL_USER|g" | \
sed "s|Group=pi|Group=$REAL_USER|g" | \
sed "s|PORT=3000|PORT=$SERVER_PORT|g" > /etc/systemd/system/borneez-server.service

# Recharger systemd
systemctl daemon-reload

# Activer les services
echo -e "${YELLOW}🔧 Activation des services...${NC}"
systemctl enable borneez-gpio.service
systemctl enable borneez-server.service

# Démarrer les services
echo -e "${YELLOW}🚀 Démarrage des services...${NC}"
systemctl start borneez-gpio.service
sleep 2
systemctl start borneez-server.service
sleep 2

echo -e "${GREEN}✅ Services configurés et démarrés${NC}"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Étape 5: Vérification du statut${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Vérifier le statut des services
echo -e "${YELLOW}📊 Statut du service GPIO:${NC}"
systemctl status borneez-gpio.service --no-pager || true

echo ""
echo -e "${YELLOW}📊 Statut du service serveur:${NC}"
systemctl status borneez-server.service --no-pager || true

if [ "$PROXY_TYPE" = "nginx" ]; then
    echo ""
    echo -e "${YELLOW}📊 Statut de Nginx:${NC}"
    systemctl status nginx --no-pager || true
elif [ "$PROXY_TYPE" = "caddy" ]; then
    echo ""
    echo -e "${YELLOW}📊 Statut de Caddy:${NC}"
    systemctl status caddy --no-pager || true
fi

# Obtenir les informations réseau
LOCAL_IP=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ INSTALLATION TERMINÉE ✅                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Application disponible sur:${NC}"

if [ "$PROXY_TYPE" != "none" ]; then
    echo -e "   Local:    ${BLUE}http://localhost${NC} (via reverse proxy)"
    echo -e "   Hostname: ${BLUE}http://$HOSTNAME.local${NC}"
    echo -e "   IP:       ${BLUE}http://$LOCAL_IP${NC}"
else
    echo -e "   Local:    ${BLUE}http://localhost${NC} (port 80, sans reverse proxy)"
    echo -e "   Hostname: ${BLUE}http://$HOSTNAME.local${NC}"
    echo -e "   IP:       ${BLUE}http://$LOCAL_IP${NC}"
fi

echo ""
echo -e "${GREEN}🔧 Backend GPIO:${NC}"
echo -e "   Local:  ${BLUE}http://localhost:8000${NC}"
echo -e "   Docs:   ${BLUE}http://localhost:8000/docs${NC}"
echo ""
echo -e "${YELLOW}📝 Commandes utiles:${NC}"
echo -e "   Voir les logs GPIO:    ${BLUE}sudo journalctl -u borneez-gpio -f${NC}"
echo -e "   Voir les logs serveur: ${BLUE}sudo journalctl -u borneez-server -f${NC}"
echo -e "   Redémarrer GPIO:       ${BLUE}sudo systemctl restart borneez-gpio${NC}"
echo -e "   Redémarrer serveur:    ${BLUE}sudo systemctl restart borneez-server${NC}"
echo -e "   Arrêter tous:          ${BLUE}sudo systemctl stop borneez-*${NC}"
echo ""

if [ "$PROXY_TYPE" = "nginx" ]; then
    echo -e "${YELLOW}💡 Pour activer HTTPS avec Let's Encrypt:${NC}"
    echo -e "   1. Assurez-vous d'avoir un nom de domaine pointant vers cette machine"
    echo -e "   2. Installez certbot: ${BLUE}sudo apt-get install certbot python3-certbot-nginx${NC}"
    echo -e "   3. Exécutez: ${BLUE}sudo certbot --nginx -d votre-domaine.com${NC}"
    echo ""
elif [ "$PROXY_TYPE" = "caddy" ]; then
    echo -e "${YELLOW}💡 Pour activer HTTPS avec Caddy:${NC}"
    echo -e "   1. Éditez /etc/caddy/Caddyfile et remplacez ':80' par votre domaine"
    echo -e "   2. Redémarrez Caddy: ${BLUE}sudo systemctl restart caddy${NC}"
    echo -e "   Caddy obtiendra automatiquement un certificat Let's Encrypt!"
    echo ""
fi

echo -e "${GREEN}✨ Installation terminée avec succès! ✨${NC}"

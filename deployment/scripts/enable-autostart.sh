#!/bin/bash

# Script pour activer/désactiver le démarrage automatique de Borneez au boot
# Ce script configure les services systemd pour démarrer automatiquement
# Usage: sudo ./enable-autostart.sh [enable|disable|status]

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
    echo "Usage: sudo ./enable-autostart.sh [enable|disable|status]"
    exit 1
fi

# Récupérer l'utilisateur réel (celui qui a lancé sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo ~$REAL_USER)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Définir l'action (enable par défaut)
ACTION=${1:-enable}

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 Borneez - Configuration Démarrage Automatique     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📂 Répertoire du projet: ${PROJECT_DIR}${NC}"
echo -e "${GREEN}👤 Utilisateur: ${REAL_USER}${NC}"
echo ""

# Fonction pour vérifier si les services existent
check_services_exist() {
    local gpio_exists=false
    local server_exists=false
    
    if [ -f "/etc/systemd/system/borneez-gpio.service" ]; then
        gpio_exists=true
    fi
    
    if [ -f "/etc/systemd/system/borneez-server.service" ]; then
        server_exists=true
    fi
    
    if [ "$gpio_exists" = false ] || [ "$server_exists" = false ]; then
        return 1
    fi
    return 0
}

# Fonction pour créer les services systemd s'ils n'existent pas
create_services() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Configuration des services systemd${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Vérifier que les fichiers source existent
    if [ ! -f "$PROJECT_DIR/deployment/systemd/borneez-gpio.service" ]; then
        echo -e "${RED}❌ Fichier source borneez-gpio.service introuvable${NC}"
        exit 1
    fi
    
    if [ ! -f "$PROJECT_DIR/deployment/systemd/borneez-server.service" ]; then
        echo -e "${RED}❌ Fichier source borneez-server.service introuvable${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}📝 Création des fichiers de service systemd...${NC}"
    
    # Détecter si un reverse proxy est installé
    # Si nginx ou caddy est actif et configuré pour Borneez, utiliser port 3000
    # Sinon, utiliser le port 80 directement
    SERVER_PORT=3000
    if systemctl is-active nginx &>/dev/null && [ -f "/etc/nginx/sites-enabled/borneez" ]; then
        echo -e "${GREEN}   Nginx détecté - Configuration avec port 3000 (reverse proxy)${NC}"
        SERVER_PORT=3000
    elif systemctl is-active caddy &>/dev/null && [ -f "/etc/caddy/Caddyfile" ]; then
        echo -e "${GREEN}   Caddy détecté - Configuration avec port 3000 (reverse proxy)${NC}"
        SERVER_PORT=3000
    else
        echo -e "${YELLOW}   Aucun reverse proxy détecté - Configuration avec port 80${NC}"
        SERVER_PORT=80
    fi
    
    # Copier et adapter le service GPIO
    sed "s|/home/pi/Borneez|$PROJECT_DIR|g" "$PROJECT_DIR/deployment/systemd/borneez-gpio.service" | \
    sed "s|User=pi|User=$REAL_USER|g" | \
    sed "s|Group=pi|Group=$REAL_USER|g" > /etc/systemd/system/borneez-gpio.service
    
    # Copier et adapter le service serveur
    sed "s|/home/pi/Borneez|$PROJECT_DIR|g" "$PROJECT_DIR/deployment/systemd/borneez-server.service" | \
    sed "s|User=pi|User=$REAL_USER|g" | \
    sed "s|Group=pi|Group=$REAL_USER|g" | \
    sed "s|PORT=3000|PORT=$SERVER_PORT|g" > /etc/systemd/system/borneez-server.service
    
    # Recharger systemd
    systemctl daemon-reload
    
    echo -e "${GREEN}✅ Services systemd créés${NC}"
    echo ""
}

# Fonction pour afficher le statut
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Statut des services Borneez${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if ! check_services_exist; then
        echo -e "${YELLOW}⚠️  Les services systemd ne sont pas encore configurés${NC}"
        echo -e "${YELLOW}   Exécutez: ${BLUE}sudo ./enable-autostart.sh enable${NC}"
        echo ""
        return
    fi
    
    echo -e "${YELLOW}📊 Service GPIO:${NC}"
    systemctl status borneez-gpio.service --no-pager || true
    echo ""
    
    echo -e "${YELLOW}📊 Service Serveur:${NC}"
    systemctl status borneez-server.service --no-pager || true
    echo ""
    
    # Vérifier si les services sont activés pour le démarrage automatique
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Configuration du démarrage automatique${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if systemctl is-enabled borneez-gpio.service &>/dev/null; then
        echo -e "   GPIO:   ${GREEN}✅ Activé${NC}"
    else
        echo -e "   GPIO:   ${RED}❌ Désactivé${NC}"
    fi
    
    if systemctl is-enabled borneez-server.service &>/dev/null; then
        echo -e "   Server: ${GREEN}✅ Activé${NC}"
    else
        echo -e "   Server: ${RED}❌ Désactivé${NC}"
    fi
    echo ""
}

# Fonction pour activer le démarrage automatique
enable_autostart() {
    # Créer les services s'ils n'existent pas
    if ! check_services_exist; then
        echo -e "${YELLOW}⚠️  Les services systemd n'existent pas encore${NC}"
        create_services
    else
        echo -e "${GREEN}✅ Les services systemd existent déjà${NC}"
        echo ""
        # Recharger au cas où les fichiers auraient changé
        systemctl daemon-reload
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Activation du démarrage automatique${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}🔧 Activation des services...${NC}"
    systemctl enable borneez-gpio.service
    systemctl enable borneez-server.service
    echo ""
    
    echo -e "${YELLOW}🚀 Démarrage des services...${NC}"
    systemctl start borneez-gpio.service
    sleep 2
    systemctl start borneez-server.service
    sleep 2
    echo ""
    
    echo -e "${GREEN}✅ Services activés et démarrés${NC}"
    echo ""
    
    # Afficher le statut
    show_status
    
    # Obtenir les informations réseau
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    HOSTNAME=$(hostname)
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           ✅ DÉMARRAGE AUTOMATIQUE ACTIVÉ ✅             ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Détecter si un reverse proxy est installé pour afficher les bonnes infos
    if systemctl is-active nginx &>/dev/null && [ -f "/etc/nginx/sites-enabled/borneez" ]; then
        echo -e "${GREEN}🌐 Application disponible sur (via Nginx):${NC}"
        echo -e "   Local:    ${BLUE}http://localhost${NC}"
        echo -e "   Hostname: ${BLUE}http://$HOSTNAME.local${NC}"
        echo -e "   IP:       ${BLUE}http://$LOCAL_IP${NC}"
    elif systemctl is-active caddy &>/dev/null && [ -f "/etc/caddy/Caddyfile" ]; then
        echo -e "${GREEN}🌐 Application disponible sur (via Caddy):${NC}"
        echo -e "   Local:    ${BLUE}http://localhost${NC}"
        echo -e "   Hostname: ${BLUE}http://$HOSTNAME.local${NC}"
        echo -e "   IP:       ${BLUE}http://$LOCAL_IP${NC}"
    else
        echo -e "${GREEN}🌐 Application disponible sur (port 80, sans reverse proxy):${NC}"
        echo -e "   Local:    ${BLUE}http://localhost${NC}"
        echo -e "   Hostname: ${BLUE}http://$HOSTNAME.local${NC}"
        echo -e "   IP:       ${BLUE}http://$LOCAL_IP${NC}"
    fi
    echo ""
    echo -e "${GREEN}🔧 Backend GPIO:${NC}"
    echo -e "   Local:  ${BLUE}http://localhost:8000${NC}"
    echo -e "   Docs:   ${BLUE}http://localhost:8000/docs${NC}"
    echo ""
    echo -e "${YELLOW}💡 Les services démarreront automatiquement au prochain redémarrage${NC}"
    echo ""
}

# Fonction pour désactiver le démarrage automatique
disable_autostart() {
    if ! check_services_exist; then
        echo -e "${YELLOW}⚠️  Les services systemd ne sont pas configurés${NC}"
        return
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Désactivation du démarrage automatique${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}🛑 Arrêt des services...${NC}"
    systemctl stop borneez-server.service || true
    systemctl stop borneez-gpio.service || true
    echo ""
    
    echo -e "${YELLOW}🔧 Désactivation des services...${NC}"
    systemctl disable borneez-gpio.service
    systemctl disable borneez-server.service
    echo ""
    
    echo -e "${GREEN}✅ Démarrage automatique désactivé${NC}"
    echo ""
    echo -e "${YELLOW}💡 Les services ne démarreront plus automatiquement au boot${NC}"
    echo -e "${YELLOW}   Pour les redémarrer manuellement, utilisez:${NC}"
    echo -e "   ${BLUE}sudo systemctl start borneez-gpio${NC}"
    echo -e "   ${BLUE}sudo systemctl start borneez-server${NC}"
    echo ""
}

# Traiter l'action demandée
case "$ACTION" in
    enable)
        enable_autostart
        ;;
    disable)
        disable_autostart
        ;;
    status)
        show_status
        ;;
    *)
        echo -e "${RED}❌ Action invalide: $ACTION${NC}"
        echo ""
        echo "Usage: sudo ./enable-autostart.sh [enable|disable|status]"
        echo ""
        echo "Actions disponibles:"
        echo "  enable  - Active le démarrage automatique au boot"
        echo "  disable - Désactive le démarrage automatique"
        echo "  status  - Affiche le statut des services"
        echo ""
        exit 1
        ;;
esac

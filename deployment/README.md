# 📦 Déploiement en Production - Borneez

Ce répertoire contient tous les fichiers nécessaires pour déployer Borneez en production avec un reverse proxy et une configuration systemd.

## 📁 Structure

```
deployment/
├── nginx/
│   ├── borneez.conf     # Configuration Nginx pour reverse proxy
│   └── Caddyfile        # Configuration Caddy (alternative à Nginx)
├── systemd/
│   ├── borneez-gpio.service     # Service systemd pour le contrôleur GPIO
│   └── borneez-server.service   # Service systemd pour le serveur proxy
└── scripts/
    └── setup-production.sh      # Script d'installation automatique
```

## 🚀 Installation Rapide (Recommandé)

### Méthode automatique avec le script d'installation

Le moyen le plus simple pour installer Borneez en production :

```bash
# Clone le projet (si ce n'est pas déjà fait)
git clone https://github.com/hackolite/Borneez.git
cd Borneez

# Lancer le script d'installation avec Nginx (recommandé)
sudo deployment/scripts/setup-production.sh nginx

# Ou avec Caddy (HTTPS automatique)
sudo deployment/scripts/setup-production.sh caddy

# Ou sans reverse proxy (application sur port 3000)
sudo deployment/scripts/setup-production.sh none
```

Le script d'installation va :
1. ✅ Installer toutes les dépendances système (Python, Node.js, Avahi)
2. ✅ Installer et configurer le reverse proxy choisi (Nginx ou Caddy)
3. ✅ Builder l'application
4. ✅ Configurer les services systemd
5. ✅ Démarrer automatiquement tous les services

Après l'installation, l'application sera accessible sur **http://raspberrypi.local** ou **http://&lt;IP_RASPBERRY&gt;**

## 🔧 Options de Déploiement

### Option 1 : Avec Nginx (Recommandé)

**Avantages :**
- Très stable et performant
- Grande communauté et documentation
- Support HTTPS facile avec Let's Encrypt

**Installation :**
```bash
sudo deployment/scripts/setup-production.sh nginx
```

**Configuration manuelle (si besoin) :**
```bash
# Installer Nginx
sudo apt-get install nginx

# Copier la configuration
sudo cp deployment/nginx/borneez.conf /etc/nginx/sites-available/borneez
sudo ln -s /etc/nginx/sites-available/borneez /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Tester et redémarrer
sudo nginx -t
sudo systemctl restart nginx
```

### Option 2 : Avec Caddy (HTTPS Automatique)

**Avantages :**
- Configuration ultra-simple
- HTTPS automatique avec Let's Encrypt (certificat SSL gratuit)
- Pas besoin de certbot

**Installation :**
```bash
sudo deployment/scripts/setup-production.sh caddy
```

**Pour activer HTTPS automatique avec Caddy :**
1. Éditez `/etc/caddy/Caddyfile`
2. Remplacez `:80` par votre nom de domaine (ex: `monsite.com`)
3. Redémarrez Caddy : `sudo systemctl restart caddy`

Caddy obtiendra automatiquement un certificat SSL gratuit !

### Option 3 : Sans Reverse Proxy

L'application tourne directement sur le port 3000.

```bash
sudo deployment/scripts/setup-production.sh none
```

Accès : `http://raspberrypi.local:3000`

## 📋 Installation Manuelle (Avancé)

Si vous préférez tout configurer manuellement :

### 1. Installer les dépendances

```bash
# Mise à jour du système
sudo apt-get update

# Python et GPIO
sudo apt-get install python3 python3-pip python3-rpi.gpio
pip3 install fastapi uvicorn pydantic

# Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt-get install -y nodejs

# mDNS (pour accès via raspberrypi.local)
sudo apt-get install avahi-daemon
```

### 2. Builder l'application

```bash
cd /chemin/vers/Borneez
npm install
npm run build
```

### 3. Configurer les services systemd

```bash
# Copier les fichiers service (adaptez les chemins si nécessaire)
sudo cp deployment/systemd/borneez-gpio.service /etc/systemd/system/
sudo cp deployment/systemd/borneez-server.service /etc/systemd/system/

# Si votre utilisateur n'est pas 'pi', éditez les fichiers :
sudo nano /etc/systemd/system/borneez-gpio.service
# Changez User=pi et WorkingDirectory=/home/pi/Borneez

sudo nano /etc/systemd/system/borneez-server.service
# Changez User=pi et WorkingDirectory=/home/pi/Borneez

# Recharger systemd
sudo systemctl daemon-reload

# Activer et démarrer les services
sudo systemctl enable borneez-gpio borneez-server
sudo systemctl start borneez-gpio
sleep 2
sudo systemctl start borneez-server
```

### 4. Configurer Nginx (optionnel)

```bash
sudo apt-get install nginx
sudo cp deployment/nginx/borneez.conf /etc/nginx/sites-available/borneez
sudo ln -s /etc/nginx/sites-available/borneez /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

## 🔒 Sécurité - Activer HTTPS

### Avec Nginx + Let's Encrypt

```bash
# Installer certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtenir un certificat SSL (remplacez par votre domaine)
sudo certbot --nginx -d votre-domaine.com

# Certbot configurera automatiquement Nginx pour HTTPS
# Le renouvellement du certificat est automatique
```

### Avec Caddy

Caddy gère automatiquement HTTPS ! Modifiez simplement `/etc/caddy/Caddyfile` :

```caddy
# Remplacez :80 par votre domaine
votre-domaine.com {
    reverse_proxy localhost:3000
}
```

Puis redémarrez : `sudo systemctl restart caddy`

## 🔄 Gestion des Services

### Commandes utiles

```bash
# Voir les logs
sudo journalctl -u borneez-gpio -f
sudo journalctl -u borneez-server -f

# Redémarrer un service
sudo systemctl restart borneez-gpio
sudo systemctl restart borneez-server

# Arrêter un service
sudo systemctl stop borneez-gpio
sudo systemctl stop borneez-server

# Statut d'un service
sudo systemctl status borneez-gpio
sudo systemctl status borneez-server

# Désactiver le démarrage automatique
sudo systemctl disable borneez-gpio
sudo systemctl disable borneez-server
```

### Redémarrage après modification du code

```bash
# 1. Rebuild l'application
cd /chemin/vers/Borneez
git pull
npm install
npm run build

# 2. Redémarrer les services
sudo systemctl restart borneez-gpio
sudo systemctl restart borneez-server

# 3. Si vous utilisez Nginx/Caddy, pas besoin de les redémarrer
```

## 🌐 Accès et URLs

Après installation, votre application est accessible via :

**Avec reverse proxy (port 80) :**
- Local : `http://localhost`
- Hostname : `http://raspberrypi.local`
- IP : `http://192.168.1.XXX`

**Sans reverse proxy (port 3000) :**
- Local : `http://localhost:3000`
- Hostname : `http://raspberrypi.local:3000`
- IP : `http://192.168.1.XXX:3000`

**Backend GPIO (toujours sur port 8000) :**
- API : `http://localhost:8000`
- Documentation : `http://localhost:8000/docs`

## 🔍 Dépannage

### Les services ne démarrent pas

```bash
# Vérifier les logs
sudo journalctl -u borneez-gpio -n 50
sudo journalctl -u borneez-server -n 50

# Vérifier que les ports sont libres
sudo lsof -i :8000
sudo lsof -i :3000
sudo lsof -i :80
```

### L'application n'est pas accessible

```bash
# Vérifier que les services tournent
sudo systemctl status borneez-gpio
sudo systemctl status borneez-server
sudo systemctl status nginx  # ou caddy

# Tester directement
curl http://localhost:8000/
curl http://localhost:3000/api/status
```

### Erreur de permission GPIO

Assurez-vous que l'utilisateur du service a accès aux GPIO :

```bash
# Ajouter l'utilisateur au groupe gpio
sudo usermod -a -G gpio votre-utilisateur

# Ou modifier le fichier service pour utiliser root (non recommandé)
# sudo nano /etc/systemd/system/borneez-gpio.service
# User=root
```

## 📊 Monitoring en Production

### Surveiller les ressources

```bash
# CPU et mémoire
htop

# Espace disque
df -h

# Logs en temps réel
sudo journalctl -f
```

### Logs rotatifs

Les logs systemd sont automatiquement gérés, mais vous pouvez configurer la rotation :

```bash
sudo nano /etc/systemd/journald.conf

# Ajouter/modifier :
SystemMaxUse=500M
SystemKeepFree=1G
```

## 🔄 Mise à Jour

```bash
cd /chemin/vers/Borneez
git pull
npm install
npm run build
sudo systemctl restart borneez-gpio borneez-server
```

## 🆘 Support

Pour plus d'aide :
- Documentation principale : [README.md](../README.md)
- Guide de déploiement : [DEPLOYMENT.md](../DEPLOYMENT.md)
- Issues GitHub : https://github.com/hackolite/Borneez/issues

---

**Note** : Ce guide suppose que vous utilisez un Raspberry Pi avec Raspberry Pi OS. Pour d'autres distributions Linux, adaptez les commandes d'installation des paquets.

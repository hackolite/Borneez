# Guide de Déploiement Borneez

## 🎯 Vue d'ensemble

Ce guide explique comment déployer Borneez dans différents scénarios.

## 📋 Scénarios de déploiement

### Scénario 1 : Tout sur le Raspberry Pi (Recommandé pour débuter)

**Architecture :**
```
[Raspberry Pi]
├── GPIO Controller (port 8000)
├── Proxy Server (port 80)
└── Frontend (servi via proxy)
```

**Avantages :**
- Simple à configurer
- Une seule machine
- Pas besoin de configuration réseau complexe

**Instructions :**

1. **Installation sur Raspberry Pi**
```bash
# Se connecter au Raspberry Pi
ssh pi@raspberrypi.local

# Cloner le projet
git clone https://github.com/hackolite/Borneez.git
cd Borneez

# Installer les dépendances Python
pip3 install fastapi uvicorn pydantic

# Installer Node.js si nécessaire
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installer les dépendances Node
npm install

# Build le frontend
npm run build
```

2. **Configurer le service GPIO**
```bash
# Créer le fichier service
sudo nano /etc/systemd/system/gpio-controller.service
```

Contenu :
```ini
[Unit]
Description=Borneez GPIO Controller
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/Borneez
ExecStart=/usr/bin/python3 /home/pi/Borneez/BGPIO.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Activer et démarrer
sudo systemctl enable gpio-controller
sudo systemctl start gpio-controller
sudo systemctl status gpio-controller
```

3. **Configurer le service Proxy**
```bash
sudo nano /etc/systemd/system/borneez-server.service
```

Contenu :
```ini
[Unit]
Description=Borneez Proxy Server
After=network.target gpio-controller.service
Requires=gpio-controller.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/pi/Borneez
Environment="NODE_ENV=production"
Environment="PORT=80"
Environment="RELAY_API_ENDPOINT=http://localhost:8000"
ExecStart=/usr/bin/node /home/pi/Borneez/dist/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Note :** Le service s'exécute en tant que `root` car le port 80 nécessite des privilèges élevés.

```bash
# Activer et démarrer
sudo systemctl enable borneez-server
sudo systemctl start borneez-server
sudo systemctl status borneez-server
```

4. **Accès**

Accédez à l'interface :
- Via IP : `http://<IP_RASPBERRY>`
- Via mDNS : `http://raspberrypi.local` (si Avahi est installé)

Pour trouver l'IP :
```bash
hostname -I
```

Pour activer l'accès mDNS :
```bash
# Installer Avahi daemon
sudo apt-get update
sudo apt-get install avahi-daemon

# Vérifier le service
sudo systemctl status avahi-daemon
```

### Scénario 2 : Proxy + Frontend sur VPS

**Architecture :**
```
[Raspberry Pi]              [VPS Cloud]
GPIO Controller ←────────── Proxy + Frontend
(port 8000)                 (port 80)
```

**Avantages :**
- Frontend accessible de partout
- Configuration centralisée
- Pas besoin d'exposer le Raspberry Pi

**Instructions :**

1. **Préparer le Raspberry Pi** (GPIO Controller uniquement)

Suivez l'étape 1 et 2 du Scénario 1 pour installer le GPIO Controller.

2. **Connecter le Raspberry Pi au VPS**

Option A - Avec VPN Tailscale (Recommandé) :
```bash
# Sur Raspberry Pi ET sur VPS
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Option B - Avec tunnel SSH :
```bash
# Sur Raspberry Pi, créer un tunnel vers le VPS
ssh -R 8000:localhost:8000 user@votre-vps.com -N
```

3. **Déployer sur le VPS**

```bash
# Sur le VPS
git clone https://github.com/hackolite/Borneez.git
cd Borneez
npm install
npm run build

# Configurer l'endpoint (via Tailscale ou tunnel)
export RELAY_API_ENDPOINT=http://100.x.x.x:8000  # IP Tailscale du Raspberry
# ou
export RELAY_API_ENDPOINT=http://localhost:8000  # Si tunnel SSH

# Démarrer (port 80 nécessite sudo)
sudo PORT=80 npm start
```

4. **Accès**

Le frontend est accessible à `http://votre-vps.com` ou `https://votre-vps.com` (configurez HTTPS, voir section Sécurité).

**Note** : Cette configuration garde le frontend et le proxy ensemble sur le VPS, ce qui correspond à l'architecture actuelle du code.

### Scénario 3 : Architecture complète cloud

**Architecture :**
```
[Raspberry Pi]           [VPS Cloud]
GPIO Controller ←──────→ Proxy + Frontend
(port 8000)              (port 80)
```

**Note** : Cette architecture est identique au Scénario 2. Pour déployer le frontend complètement séparément (ex: Vercel), il faudrait modifier le code pour supporter `VITE_API_URL` et configurer CORS sur le proxy.

**Pour l'instant, la meilleure architecture distribuée est le Scénario 2 ci-dessus.**

## 🔒 Sécurité

### Pour un accès public

1. **Utiliser HTTPS**

Avec Nginx reverse proxy :
```bash
# Installer Nginx et Certbot
sudo apt-get install nginx certbot python3-certbot-nginx

# Configurer Nginx
sudo nano /etc/nginx/sites-available/borneez
```

Configuration :
```nginx
server {
    listen 80;
    server_name votre-domaine.com;

    location / {
        proxy_pass http://localhost:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Note :** Si votre serveur Borneez tourne sur le port 80, Nginx doit écouter sur un port différent ou vous pouvez configurer Borneez sur un autre port et faire du reverse proxy.

```bash
# Activer et obtenir certificat SSL
sudo ln -s /etc/nginx/sites-available/borneez /etc/nginx/sites-enabled/
sudo certbot --nginx -d votre-domaine.com
```

2. **Ajouter une authentification**

Créer un fichier `.htpasswd` :
```bash
# Installer apache2-utils
sudo apt-get install apache2-utils

# Créer un utilisateur
sudo htpasswd -c /etc/nginx/.htpasswd admin
```

Modifier Nginx config :
```nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    proxy_pass http://localhost:80;
    # ...
}
```

3. **Configurer un firewall**
```bash
# UFW (Ubuntu)
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

## 📊 Monitoring

### Logs

**GPIO Controller :**
```bash
sudo journalctl -u gpio-controller -f
```

**Proxy Server :**
```bash
sudo journalctl -u borneez-server -f
```

### Redémarrage automatique

Les services systemd redémarrent automatiquement en cas de crash.

Pour redémarrer manuellement :
```bash
sudo systemctl restart gpio-controller
sudo systemctl restart borneez-server
```

## 🔄 Mise à jour

```bash
# Se connecter au Raspberry Pi
cd Borneez

# Sauvegarder la config actuelle
cp server/storage.ts server/storage.ts.backup

# Récupérer les mises à jour
git pull

# Réinstaller les dépendances si nécessaire
npm install

# Rebuild
npm run build

# Redémarrer les services
sudo systemctl restart gpio-controller
sudo systemctl restart borneez-server
```

## 🐛 Dépannage

### Vérifier que les services fonctionnent
```bash
# Status des services
sudo systemctl status gpio-controller
sudo systemctl status borneez-server

# Vérifier les ports
sudo netstat -tlnp | grep -E '80|8000'
```

### Tester directement
```bash
# GPIO Controller
curl http://localhost:8000/

# Proxy Server
curl http://localhost/api/status
```

### Problèmes courants

**Service ne démarre pas :**
```bash
# Vérifier les logs
sudo journalctl -u gpio-controller -n 50
sudo journalctl -u borneez-server -n 50
```

**Port déjà utilisé :**
```bash
# Trouver le processus
sudo lsof -i :80

# Arrêter le processus
sudo kill -9 <PID>
```

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation complète dans README.md

# Guide de Déploiement Borneez

## 🎯 Vue d'ensemble

Ce guide explique comment déployer Borneez dans différents scénarios.

## 📋 Scénarios de déploiement

### Scénario 1 : Tout sur le Raspberry Pi (Recommandé pour débuter)

**Architecture :**
```
[Raspberry Pi]
├── GPIO Controller (port 8000)
├── Proxy Server (port 5000)
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
User=pi
WorkingDirectory=/home/pi/Borneez
Environment="NODE_ENV=production"
Environment="PORT=5000"
Environment="RELAY_API_ENDPOINT=http://localhost:8000"
ExecStart=/usr/bin/node /home/pi/Borneez/dist/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Activer et démarrer
sudo systemctl enable borneez-server
sudo systemctl start borneez-server
sudo systemctl status borneez-server
```

4. **Accès**

Accédez à l'interface : `http://<IP_RASPBERRY>:5000`

Pour trouver l'IP :
```bash
hostname -I
```

### Scénario 2 : Frontend déployé sur Vercel/Netlify

**Architecture :**
```
[Raspberry Pi]              [Cloud]
├── GPIO Controller ←──────→ Frontend (Vercel/Netlify)
└── Proxy Server
```

**Avantages :**
- Interface accessible de partout
- Performance optimale
- CDN global

**Instructions :**

1. **Préparer le Raspberry Pi** (comme Scénario 1)

2. **Rendre le Raspberry Pi accessible**

Option A - Avec VPN (Recommandé) :
```bash
# Installer Tailscale (VPN mesh)
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Option B - Avec port forwarding (moins sécurisé) :
- Configurez votre routeur pour forward le port 5000
- Utilisez un DNS dynamique (DuckDNS, No-IP)

3. **Déployer sur Vercel**

```bash
# Local
npm install -g vercel

# Se connecter
vercel login

# Déployer
vercel --prod

# Configuration build :
# Build Command: npm run build
# Output Directory: dist/client
```

4. **Configurer l'endpoint**

Une fois déployé sur Vercel :
1. Visitez votre URL Vercel
2. Allez dans "API Configuration"
3. Entrez l'URL de votre Raspberry Pi :
   - Avec Tailscale : `http://100.x.x.x:5000` (IP Tailscale)
   - Avec port forwarding : `http://votre-domaine.duckdns.org:5000`

### Scénario 3 : Architecture complète cloud

**Architecture :**
```
[Raspberry Pi]           [VPS Cloud]              [Vercel]
GPIO Controller ←──────→ Proxy Server ←──────────→ Frontend
(port 8000)              (port 5000)
```

**Avantages :**
- Séparation complète
- Scalabilité maximale
- Sécurité améliorée

**Instructions :**

1. **Sur Raspberry Pi** - GPIO Controller uniquement

```bash
# Modifier BGPIO.py pour accepter uniquement localhost
# (le proxy sera le seul à y accéder via tunnel)
```

Créer un tunnel SSH vers le VPS :
```bash
# Sur Raspberry Pi
ssh -R 8000:localhost:8000 user@votre-vps.com -N
```

Ou utiliser un tunnel permanent comme Tailscale.

2. **Sur VPS Cloud** - Proxy Server

```bash
# Sur le VPS
git clone https://github.com/hackolite/Borneez.git
cd Borneez
npm install
npm run build

# Configurer l'endpoint
export RELAY_API_ENDPOINT=http://localhost:8000  # Via tunnel

# Démarrer
npm start
```

3. **Sur Vercel** - Frontend (comme Scénario 2)

Configurez l'endpoint vers votre VPS : `https://votre-vps.com:5000`

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
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

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
    
    proxy_pass http://localhost:5000;
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
sudo netstat -tlnp | grep -E '5000|8000'
```

### Tester directement
```bash
# GPIO Controller
curl http://localhost:8000/

# Proxy Server
curl http://localhost:5000/api/status
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
sudo lsof -i :5000

# Arrêter le processus
sudo kill -9 <PID>
```

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation complète dans README.md

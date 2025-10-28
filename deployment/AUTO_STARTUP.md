# Démarrage Automatique de Borneez

Ce document explique comment configurer le démarrage automatique de l'application Borneez au démarrage du Raspberry Pi, avec gestion automatique de l'environnement virtuel Python.

## 🎯 Vue d'ensemble

Le système de démarrage automatique utilise :
- **Environnement virtuel Python** : Toutes les dépendances Python sont isolées dans `./venv`
- **Services systemd** : Deux services qui démarrent automatiquement au boot
  - `borneez-gpio.service` : Contrôleur GPIO (FastAPI)
  - `borneez-server.service` : Serveur proxy (Node.js/Express)

## 🚀 Installation Rapide (Recommandé)

La méthode la plus simple pour configurer le démarrage automatique :

```bash
# Se connecter au Raspberry Pi
ssh pi@raspberrypi.local

# Cloner le projet si ce n'est pas déjà fait
git clone https://github.com/hackolite/Borneez.git
cd Borneez

# Lancer l'installation automatique
sudo deployment/scripts/setup-production.sh nginx
```

Cette commande :
- ✅ Installe toutes les dépendances système
- ✅ Crée l'environnement virtuel Python
- ✅ Installe les dépendances Python dans le venv
- ✅ Configure les services systemd
- ✅ Active le démarrage automatique
- ✅ Configure Nginx comme reverse proxy (optionnel : remplacez `nginx` par `caddy` ou `none`)

## 🔧 Installation Manuelle

Si vous préférez configurer manuellement :

### Étape 1 : Préparer l'environnement

```bash
# Installer les dépendances système
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip python3-rpi.gpio

# Cloner et préparer le projet
git clone https://github.com/hackolite/Borneez.git
cd Borneez

# Créer l'environnement virtuel
./scripts/setup-venv.sh

# Installer les dépendances Node.js
npm install

# Build l'application
npm run build
```

### Étape 2 : Configurer les services systemd

#### Service GPIO

Créer le fichier `/etc/systemd/system/borneez-gpio.service` :

```ini
[Unit]
Description=Borneez GPIO Controller Service
Documentation=https://github.com/hackolite/Borneez
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/Borneez

# Utilise l'environnement virtuel Python
ExecStart=/home/pi/Borneez/venv/bin/python /home/pi/Borneez/BGPIO.py

# Redémarrage automatique en cas d'échec
Restart=always
RestartSec=10

# Logs
StandardOutput=journal
StandardError=journal
SyslogIdentifier=borneez-gpio

# Sécurité
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

#### Service Proxy/Server

Créer le fichier `/etc/systemd/system/borneez-server.service` :

```ini
[Unit]
Description=Borneez Proxy Server Service
Documentation=https://github.com/hackolite/Borneez
After=network.target borneez-gpio.service
Wants=network-online.target
Requires=borneez-gpio.service

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/Borneez

# Variables d'environnement
Environment="NODE_ENV=production"
Environment="PORT=3000"
Environment="RELAY_API_ENDPOINT=http://localhost:8000"

# Commande pour démarrer le serveur proxy
ExecStart=/usr/bin/node /home/pi/Borneez/dist/index.js

# Redémarrage automatique en cas d'échec
Restart=always
RestartSec=10

# Logs
StandardOutput=journal
StandardError=journal
SyslogIdentifier=borneez-server

# Sécurité
NoNewPrivileges=true
PrivateTmp=true
ReadWritePaths=/home/pi/Borneez

[Install]
WantedBy=multi-user.target
```

### Étape 3 : Activer et démarrer les services

```bash
# Recharger systemd
sudo systemctl daemon-reload

# Activer le démarrage automatique
sudo systemctl enable borneez-gpio.service
sudo systemctl enable borneez-server.service

# Démarrer les services
sudo systemctl start borneez-gpio.service
sudo systemctl start borneez-server.service

# Vérifier le statut
sudo systemctl status borneez-gpio.service
sudo systemctl status borneez-server.service
```

## 📊 Gestion des Services

### Commandes utiles

```bash
# Démarrer les services
sudo systemctl start borneez-gpio borneez-server

# Arrêter les services
sudo systemctl stop borneez-gpio borneez-server

# Redémarrer les services
sudo systemctl restart borneez-gpio borneez-server

# Voir les logs en temps réel
sudo journalctl -u borneez-gpio -f
sudo journalctl -u borneez-server -f

# Voir les derniers logs
sudo journalctl -u borneez-gpio -n 50
sudo journalctl -u borneez-server -n 50

# Désactiver le démarrage automatique
sudo systemctl disable borneez-gpio borneez-server
```

### Vérifier que tout fonctionne

```bash
# Vérifier que les services sont actifs
systemctl is-active borneez-gpio
systemctl is-active borneez-server

# Vérifier que les services sont activés au démarrage
systemctl is-enabled borneez-gpio
systemctl is-enabled borneez-server

# Tester l'accès à l'API GPIO
curl http://localhost:8000/

# Tester l'accès au serveur proxy
curl http://localhost:3000/api/status
```

## 🔍 Dépannage

### Service ne démarre pas

```bash
# Voir les logs détaillés
sudo journalctl -u borneez-gpio -xe
sudo journalctl -u borneez-server -xe

# Vérifier la configuration du service
sudo systemctl cat borneez-gpio
sudo systemctl cat borneez-server
```

### Problèmes avec l'environnement virtuel

```bash
# Recréer l'environnement virtuel
cd /home/pi/Borneez
rm -rf venv
./scripts/setup-venv.sh

# Redémarrer le service
sudo systemctl restart borneez-gpio
```

### Le service démarre mais crash

```bash
# Tester manuellement avec le venv
cd /home/pi/Borneez
./venv/bin/python BGPIO.py

# Vérifier les dépendances
./venv/bin/pip list

# Vérifier les permissions
ls -la /home/pi/Borneez/venv
```

### Port déjà utilisé

```bash
# Trouver quel processus utilise le port 8000
sudo lsof -i :8000

# Arrêter le processus si nécessaire
sudo kill -9 <PID>
```

## 🔄 Mise à jour

Pour mettre à jour l'application :

```bash
cd /home/pi/Borneez

# Récupérer les mises à jour
git pull

# Mettre à jour les dépendances Python si nécessaire
./venv/bin/pip install -r requirements.txt

# Mettre à jour les dépendances Node.js si nécessaire
npm install

# Rebuild l'application
npm run build

# Redémarrer les services
sudo systemctl restart borneez-gpio borneez-server
```

## ✅ Avantages de cette Configuration

1. **Isolation des dépendances** : L'environnement virtuel Python garde les dépendances isolées
2. **Démarrage automatique** : Les services démarrent automatiquement au boot du Raspberry Pi
3. **Redémarrage automatique** : Si un service crash, il redémarre automatiquement
4. **Logs centralisés** : Les logs sont disponibles via `journalctl`
5. **Gestion simple** : Contrôle facile via `systemctl`
6. **Sécurité** : Services fonctionnent avec des privilèges limités
7. **Dépendances** : Le service serveur attend que le service GPIO soit prêt

## 📝 Notes Importantes

- **RPi.GPIO** : Ce package est installé au niveau système (via `apt-get`) car il nécessite un accès direct au matériel. Un lien symbolique est créé dans le venv pour y accéder.
- **Port 3000** : Par défaut, le serveur écoute sur le port 3000. Utilisez Nginx ou Caddy pour exposer sur le port 80.
- **Permissions** : Les services s'exécutent en tant qu'utilisateur `pi` pour des raisons de sécurité.
- **PATH venv** : Le chemin `/home/pi/Borneez/venv/bin/python` est codé en dur dans les services. Adaptez-le si vous installez ailleurs.

## 🆘 Support

En cas de problème :
1. Vérifiez les logs avec `journalctl`
2. Testez manuellement les commandes
3. Vérifiez que l'environnement virtuel est correctement configuré
4. Consultez la documentation complète dans [DEPLOYMENT.md](../DEPLOYMENT.md)

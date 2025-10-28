# Borneez - Contrôleur GPIO Raspberry Pi avec REST API

![Architecture](https://img.shields.io/badge/Architecture-REST%20API-blue)
![Backend](https://img.shields.io/badge/Backend-FastAPI%20%2B%20Express-green)
![Frontend](https://img.shields.io/badge/Frontend-React%20%2B%20TypeScript-61dafb)

Un système complet pour contrôler les GPIO du Raspberry Pi via une architecture REST API moderne avec frontend React déployable n'importe où.

## 📋 Table des matières

- [Architecture](#-architecture)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Structure du projet](#-structure-du-projet)
- [API Documentation](#-api-documentation)
- [Déploiement](#-déploiement)
- [Dépannage](#-dépannage)

## 🏗️ Architecture

Le projet est organisé en **trois couches séparées** :

```
┌─────────────────────────────────────────────────────────┐
│                   FRONTEND (React)                       │
│  Déployable n'importe où (Vercel, Netlify, etc.)       │
│                localhost:5173 en dev                     │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST API
                     │
┌────────────────────▼────────────────────────────────────┐
│           PROXY SERVER (Express/TypeScript)             │
│        Gère la configuration et proxy les requêtes      │
│      localhost ou raspberrypi.local (port 80)           │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST API
                     │
┌────────────────────▼────────────────────────────────────┐
│         GPIO CONTROLLER (FastAPI/Python)                │
│    Contrôle direct des GPIO du Raspberry Pi            │
│         localhost:8000 (sur Raspberry Pi)               │
└─────────────────────────────────────────────────────────┘
```

### Pourquoi cette architecture ?

1. **Séparation des responsabilités** : Le frontend peut être déployé sur n'importe quel hébergeur web
2. **Sécurité** : Le serveur GPIO n'est pas directement exposé au frontend
3. **Flexibilité** : Changez facilement l'endpoint du contrôleur GPIO sans redéployer
4. **Type-safety** : Schémas partagés entre frontend et backend via TypeScript/Zod

## ✨ Fonctionnalités

### Backend (BGPIO.py - FastAPI)
- ✅ Contrôle direct des GPIO du Raspberry Pi
- ✅ Support des relais actifs bas (configurable)
- ✅ API REST complète (contrôle individuel et collectif)
- ✅ Validation des données avec Pydantic
- ✅ Documentation automatique (Swagger/OpenAPI)

### Proxy Server (Express/TypeScript)
- ✅ Gestion de la configuration de l'endpoint GPIO
- ✅ Cache local de l'état des relais
- ✅ Type-safety avec Zod schemas
- ✅ Support du développement avec Vite

### Frontend (React/TypeScript)
- ✅ Interface moderne et responsive
- ✅ Thème clair/sombre
- ✅ Configuration de l'endpoint API en temps réel
- ✅ Auto-refresh configurable
- ✅ Indicateurs de statut de connexion
- ✅ Contrôle individuel et maître de tous les relais
- ✅ Déployable sur n'importe quel hébergeur statique

## 🔧 Prérequis

### Sur le Raspberry Pi
```bash
# Python 3.8+
python3 --version

# Installation des dépendances GPIO
sudo apt-get update
sudo apt-get install python3-rpi.gpio
pip3 install fastapi uvicorn pydantic
```

### Sur la machine de développement
```bash
# Node.js 18+
node --version
npm --version
```

## 📦 Installation

### 1. Cloner le projet
```bash
git clone https://github.com/hackolite/Borneez.git
cd Borneez
```

### 2. Installer les dépendances frontend/proxy
```bash
npm install
```

### 3. Configurer les GPIO (sur Raspberry Pi)

Éditez `BGPIO.py` ligne 46 pour correspondre à votre câblage :
```python
# Exemple : GPIO 17, 27, 22, 23
relais = RelayController([17, 27, 22, 23])
```

## ⚙️ Configuration

### Variables d'environnement (optionnel)

Créez un fichier `.env` à la racine :
```env
# Endpoint de l'API GPIO (optionnel, peut être configuré via l'interface)
RELAY_API_ENDPOINT=http://192.168.1.100:8000

# Port du serveur proxy
# Par défaut: 80 (port HTTP standard - nécessite sudo sur Linux/Mac)
# Développement: 5000 (pas besoin de sudo)
PORT=80
```

### Configuration mDNS pour accès via raspberrypi.local

Pour accéder au système via un nom de domaine local (ex: `raspberrypi.local`) au lieu d'une adresse IP :

**Sur Raspberry Pi (Linux) :**
```bash
# Installer Avahi (daemon mDNS)
sudo apt-get update
sudo apt-get install avahi-daemon

# Vérifier que le service est actif
sudo systemctl status avahi-daemon

# Le système sera accessible via: http://raspberrypi.local
# (ou http://<votre-hostname>.local si vous avez changé le hostname)
```

**Changer le hostname (optionnel) :**
```bash
# Voir le hostname actuel
hostname

# Changer le hostname
sudo raspi-config
# Sélectionner: System Options > Hostname > Entrer le nouveau nom

# Ou directement:
sudo hostnamectl set-hostname nouveau-nom

# Redémarrer
sudo reboot
```

Après configuration, vous pourrez accéder au système via :
- `http://raspberrypi.local` (si hostname = raspberrypi)
- `http://votre-nom.local` (si vous avez changé le hostname)

## 🚀 Utilisation

### ⚡ Démarrage Rapide (Recommandé)

#### Option 1 : Tout en un - Mode Développement

Le moyen le plus simple pour démarrer le système :

**Linux/Mac :**
```bash
./start-dev.sh
```

**Windows :**
```batch
start-dev.bat
```

**Ou avec npm :**
```bash
npm run dev:full
```

Ces commandes démarrent automatiquement :
- ✅ Backend GPIO
- ✅ Frontend + Proxy Server
- ✅ Configuration automatique

Une fois démarré :
1. Ouvrez `http://localhost:5000` (mode développement avec port 5000)
2. Cliquez sur "API Configuration"
3. Entrez : `http://localhost:8000`
4. Cliquez sur "Test Connection" puis "Save Configuration"
5. Contrôlez les relais depuis l'interface !

> **Note :** En mode développement, le port 5000 est utilisé pour éviter d'avoir besoin de privilèges sudo.

#### Option 2 : Sur Raspberry Pi (Contrôle GPIO Réel)

**Sur le Raspberry Pi :**
```bash
./start-rpi.sh
```

Cette commande démarre :
- ✅ Backend GPIO avec contrôle matériel réel
- ✅ Frontend + Proxy Server (port 80)
- ✅ Accessible depuis le réseau local

Une fois démarré :
- Local : `http://localhost`
- mDNS : `http://raspberrypi.local` (si Avahi est installé)
- Réseau : `http://<IP_RASPBERRY>`

> **Note :** Le port 80 nécessite `sudo`. Le script vous demandera le mot de passe au démarrage.

### 🔧 Mode développement manuel (avancé)

Si vous préférez démarrer les services séparément :

#### Étape 1 : Démarrer le contrôleur GPIO

```bash
python3 BGPIO.py
# ou
npm run dev:backend
# ou avec uvicorn
uvicorn BGPIO:app --host 0.0.0.0 --port 8000
```

Le serveur GPIO démarre sur `http://localhost:8000`
Documentation automatique : `http://localhost:8000/docs`

#### Étape 2 : Démarrer le serveur proxy + frontend
```bash
npm run dev
```

Le serveur démarre sur `http://localhost:5000` (développement)

En production sur Raspberry Pi, utilisez le port 80 :
```bash
# Avec sudo pour le port 80
sudo PORT=80 npm run dev

# Le serveur sera accessible sur http://localhost (sans port)
```

#### Étape 3 : Configurer l'endpoint dans l'interface

1. Ouvrez `http://localhost:5000` (développement) ou `http://raspberrypi.local` (production)
2. Dans le panneau "API Configuration", entrez l'URL :
   - Développement local : `http://localhost:8000`
   - Raspberry Pi distant : `http://192.168.1.100:8000`
3. Cliquez sur "Test Connection" pour vérifier
4. Cliquez sur "Save Configuration"

### Mode production

#### ⚡ Démarrage Rapide Production (Recommandé)

**Méthode 1 : Installation automatique avec reverse proxy (Nginx/Caddy)**

Pour une installation complète en production avec reverse proxy et services systemd :

```bash
# Installation complète avec Nginx (recommandé)
sudo deployment/scripts/setup-production.sh nginx

# Ou avec Caddy (HTTPS automatique)
sudo deployment/scripts/setup-production.sh caddy
```

Le script configure automatiquement :
- ✅ Toutes les dépendances système
- ✅ Reverse proxy (Nginx ou Caddy) sur port 80
- ✅ Services systemd pour démarrage automatique
- ✅ Support mDNS (accès via raspberrypi.local)

**Méthode 2 : Démarrage manuel sur port 80**

```bash
# Démarrage rapide en production (port 80)
sudo ./start-production.sh

# Ou sur un autre port
PORT=3000 ./start-production.sh
```

**Méthode 3 : Démarrage traditionnel**

```bash
# Build du frontend
npm run build

# Démarrer le serveur production
# Port 80 (nécessite sudo sur Linux/Mac)
sudo PORT=80 npm start

# Ou utiliser un port personnalisé
PORT=3000 npm start
```

Le système sera accessible sur :
- Port 80 : `http://raspberrypi.local` ou `http://<IP_RASPBERRY>`
- Autre port : `http://raspberrypi.local:3000` ou `http://<IP_RASPBERRY>:3000`

> **📖 Pour plus de détails sur le déploiement en production** :
> - Guide complet : [deployment/README.md](deployment/README.md)
> - Quickstart : [QUICKSTART_PRODUCTION.md](QUICKSTART_PRODUCTION.md)
> - Configuration avancée : [DEPLOYMENT.md](DEPLOYMENT.md)

## 📁 Structure du projet

```
Borneez/
├── BGPIO.py                 # ⚡ Serveur FastAPI pour contrôle GPIO
├── start-dev.sh             # 🚀 Script de démarrage rapide (Linux/Mac)
├── start-dev.bat            # 🚀 Script de démarrage rapide (Windows)
├── start-rpi.sh             # 🍓 Script de démarrage Raspberry Pi
├── server/                  # 🖥️ Serveur proxy Express/TypeScript
│   ├── index.ts            # Point d'entrée du serveur
│   ├── routes.ts           # Routes API du proxy
│   ├── storage.ts          # Gestion de l'état et configuration
│   └── vite.ts             # Configuration Vite pour dev/prod
├── client/                  # 🎨 Application React frontend
│   ├── src/
│   │   ├── App.tsx         # Composant racine
│   │   ├── pages/
│   │   │   └── dashboard.tsx  # Page principale du dashboard
│   │   ├── components/     # Composants React réutilisables
│   │   └── lib/           # Utilitaires (QueryClient, etc.)
│   └── index.html         # HTML de base
├── shared/                 # 📦 Schémas partagés (TypeScript)
│   └── schema.ts          # Définitions Zod pour validation
├── package.json           # Dépendances Node.js
└── README.md             # 📖 Ce fichier
```

## 📡 API Documentation

### API GPIO (FastAPI - BGPIO.py)

#### GET `/`
Retourne le statut de l'API et les GPIO configurés.

**Réponse :**
```json
{
  "message": "API relais opérationnelle ✅",
  "pins": [17, 27, 22, 23]
}
```

#### POST `/relay`
Contrôle un relais spécifique.

**Corps de la requête :**
```json
{
  "gpio": 17,
  "state": "on"  // "on" ou "off"
}
```

**Réponse :**
```json
{
  "gpio": 17,
  "state": "on"
}
```

#### POST `/relay/all_on`
Active tous les relais.

**Réponse :**
```json
{
  "message": "Tous les relais activés."
}
```

#### POST `/relay/all_off`
Désactive tous les relais.

**Réponse :**
```json
{
  "message": "Tous les relais désactivés."
}
```

### API Proxy (Express - server/routes.ts)

#### GET `/api/status`
Vérifie la connexion au contrôleur GPIO.

**Réponse :**
```json
{
  "connected": true,
  "message": "API relais opérationnelle ✅",
  "pins": [17, 27, 22, 23]
}
```

#### GET `/api/relays`
Récupère l'état de tous les relais.

**Réponse :**
```json
[
  {
    "gpio": 17,
    "name": "Relay 1",
    "state": "off",
    "lastUpdated": "14:30:45"
  },
  ...
]
```

#### POST `/api/relay`
Contrôle un relais (proxied vers GPIO controller).

#### POST `/api/relay/all_on`
Active tous les relais (proxied).

#### POST `/api/relay/all_off`
Désactive tous les relais (proxied).

#### GET `/api/config/endpoint`
Récupère l'endpoint configuré.

#### POST `/api/config/endpoint`
Configure l'endpoint du contrôleur GPIO.

**Corps :**
```json
{
  "endpoint": "http://192.168.1.100:8000"
}
```

## 🌐 Déploiement

### Option 1 : Déploiement local (tout sur Raspberry Pi)

1. **Démarrer le contrôleur GPIO :**
```bash
# En tant que service systemd (recommandé)
sudo nano /etc/systemd/system/gpio-controller.service
```

Contenu :
```ini
[Unit]
Description=GPIO Controller API
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/Borneez
ExecStart=/usr/bin/python3 /home/pi/Borneez/BGPIO.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable gpio-controller
sudo systemctl start gpio-controller
```

2. **Build et démarrer le serveur :**
```bash
npm run build
npm start
```

Accédez à `http://<IP_RASPBERRY>` (port 80) ou `http://raspberrypi.local`

### Option 2 : Déploiement sur VPS avec frontend et proxy

Le proxy server et le frontend peuvent être déployés ensemble sur un VPS :

```bash
# Sur le VPS
git clone https://github.com/hackolite/Borneez.git
cd Borneez
npm install
npm run build

# Configurer l'endpoint vers le Raspberry Pi
export RELAY_API_ENDPOINT=http://<IP_RASPBERRY>:8000

# Démarrer (port 80 nécessite sudo)
sudo PORT=80 npm start
```

Accédez à `http://<IP_VPS>` ou `http://votre-domaine.com`

**Note** : Le frontend actuel utilise des URLs relatives et doit être servi par le même serveur que l'API proxy. Pour un déploiement complètement découplé (ex: Vercel pour le frontend seul), il faudrait ajouter la configuration `VITE_API_URL`.

### Option 3 : Architecture complète cloud

1. **Raspberry Pi** : Contrôleur GPIO uniquement (port 8000)
2. **Serveur VPS** : Proxy Express (port 80 ou votre choix)
3. **Hébergeur statique** : Frontend React

## 🔍 Dépannage

### Le frontend ne peut pas se connecter au backend

**Vérification :**
```bash
# Tester le contrôleur GPIO directement
curl http://<IP_RASPBERRY>:8000/

# Tester le proxy (sans port si port 80)
curl http://raspberrypi.local/api/status
# ou avec IP
curl http://<IP_RASPBERRY>/api/status
```

**Solutions :**
- Vérifiez que le firewall autorise les ports (8000, 80)
- Vérifiez l'URL configurée dans l'interface
- Regardez les logs du serveur
- Sur Linux/Mac, assurez-vous d'utiliser `sudo` pour le port 80

### Erreur "GPIO not found"

Les GPIO doivent correspondre à votre câblage. Vérifiez :
```python
# Dans BGPIO.py
relais = RelayController([17, 27, 22, 23])  # Vos GPIO ici
```

### Erreur TypeScript lors du build

```bash
# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install
```

### Les relais ne répondent pas

1. Vérifiez le câblage
2. Vérifiez la configuration `active_low` dans BGPIO.py :
```python
# Pour relais actifs bas (la plupart)
relais = RelayController([17, 27, 22, 23], active_low=True)

# Pour relais actifs haut
relais = RelayController([17, 27, 22, 23], active_low=False)
```

## 🧪 Tests

### Tester le contrôleur GPIO
```bash
# Documentation interactive
http://<IP_RASPBERRY>:8000/docs

# Test manuel avec curl
curl -X POST http://<IP_RASPBERRY>:8000/relay \
  -H "Content-Type: application/json" \
  -d '{"gpio": 17, "state": "on"}'
```

### Tester le proxy
```bash
curl http://localhost:5000/api/status
```

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 Licence

MIT

## 👥 Auteurs

- [@hackolite](https://github.com/hackolite)

## 🙏 Remerciements

- FastAPI pour l'API backend
- React et TypeScript pour le frontend moderne
- shadcn/ui pour les composants UI
- La communauté Raspberry Pi

---

**Note** : Ce projet est conçu pour le Raspberry Pi mais peut être adapté pour d'autres plateformes supportant les GPIO (comme BeagleBone, etc.).

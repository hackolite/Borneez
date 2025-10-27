# Borneez - Documentation Sommaire

## 📌 Résumé du Projet

**Borneez** est un système complet de contrôle GPIO pour Raspberry Pi avec une architecture REST API moderne et une interface web React déployable n'importe où.

## 🎯 Réponse à la Demande

Voici l'organisation demandée du code :

### 1. ✅ Serveur REST API pour GPIO Raspberry Pi

**Fichier : `BGPIO.py`**
- API REST avec FastAPI
- Contrôle direct des GPIO du Raspberry Pi
- Routes :
  - `GET /` : Status de l'API
  - `POST /relay` : Contrôler un relais
  - `POST /relay/all_on` : Activer tous les relais
  - `POST /relay/all_off` : Désactiver tous les relais

**Port :** 8000 (configurable)

### 2. ✅ Frontend déployable n'importe où

**Dossier : `client/`**
- Application React moderne avec TypeScript
- Interface responsive avec thème clair/sombre
- Déployable sur Vercel, Netlify, ou n'importe quel hébergeur
- Configuration dynamique de l'endpoint backend

**Technologies :** React, TypeScript, TanStack Query, Tailwind CSS

### 3. ✅ Serveur proxy (middleware)

**Dossier : `server/`**
- Serveur Express avec TypeScript
- Fait le pont entre le frontend et le backend GPIO
- Gère la configuration et le cache d'état
- Peut servir le frontend en production

**Port :** 5000 (configurable)

### 4. ✅ Cohérence frontend-backend

**Dossier : `shared/`**
- Schémas partagés avec Zod
- Type-safety complet
- Validation des données à tous les niveaux
- Contrat d'API unifié

## 📂 Structure du Projet

```
Borneez/
│
├── BGPIO.py                 # ⚡ Backend GPIO (FastAPI)
│
├── server/                  # 🖥️ Proxy Server (Express)
│   ├── index.ts            # Point d'entrée
│   ├── routes.ts           # Routes API
│   ├── storage.ts          # Gestion état/config
│   └── vite.ts             # Setup Vite
│
├── client/                  # 🎨 Frontend (React)
│   ├── src/
│   │   ├── App.tsx
│   │   ├── pages/
│   │   │   └── dashboard.tsx
│   │   └── components/
│   └── index.html
│
├── shared/                  # 📦 Schémas partagés
│   └── schema.ts
│
└── docs/
    ├── README.md           # Documentation complète
    ├── QUICKSTART.md       # Démarrage rapide (5 min)
    ├── DEPLOYMENT.md       # Guide de déploiement
    └── ARCHITECTURE.md     # Architecture détaillée
```

## 🚀 Tutoriel en 3 Étapes

### Étape 1 : Installation (2 minutes)

```bash
# Cloner le projet
git clone https://github.com/hackolite/Borneez.git
cd Borneez

# Installer les dépendances
npm install
pip3 install fastapi uvicorn pydantic

# Sur Raspberry Pi uniquement
sudo apt-get install python3-rpi.gpio
```

### Étape 2 : Configuration (1 minute)

Modifier `BGPIO.py` ligne 46 avec vos GPIO :
```python
relais = RelayController([17, 27, 22, 23])
```

### Étape 3 : Lancement (2 minutes)

**Terminal 1 - Backend GPIO (sur Raspberry Pi) :**
```bash
python3 BGPIO.py
```

**Terminal 2 - Frontend + Proxy :**
```bash
npm run dev
```

**Navigateur :**
1. Ouvrir `http://localhost:5000`
2. Configurer l'endpoint : `http://IP_RASPBERRY:8000`
3. Tester la connexion
4. Utiliser ! 🎉

## 📖 Tutoriels Disponibles

| Fichier | Description | Temps |
|---------|-------------|-------|
| **README.md** | Documentation complète avec architecture, API, déploiement | 30 min |
| **QUICKSTART.md** | Guide de démarrage rapide pour tester en 5 minutes | 5 min |
| **DEPLOYMENT.md** | Guide de déploiement en production avec sécurité | 20 min |
| **ARCHITECTURE.md** | Architecture technique détaillée avec diagrammes | 15 min |

## 🏗️ Architecture en 3 Couches

```
┌─────────────────────────────────┐
│   FRONTEND (React)              │  ← Déployable partout
│   localhost:5173 (dev)          │
└────────────┬────────────────────┘
             │ REST API
┌────────────▼────────────────────┐
│   PROXY (Express)               │  ← Gestion config
│   localhost:5000                │
└────────────┬────────────────────┘
             │ REST API
┌────────────▼────────────────────┐
│   GPIO API (FastAPI)            │  ← Sur Raspberry Pi
│   localhost:8000                │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│   HARDWARE GPIO                 │  ← Relais physiques
└─────────────────────────────────┘
```

## 🔌 API Endpoints

### Backend GPIO (FastAPI)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/` | Status API + pins configurés |
| POST | `/relay` | Contrôler un relais |
| POST | `/relay/all_on` | Activer tous les relais |
| POST | `/relay/all_off` | Désactiver tous les relais |

### Proxy (Express)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/status` | Test connexion GPIO |
| GET | `/api/relays` | État de tous les relais |
| POST | `/api/relay` | Contrôler un relais (proxy) |
| POST | `/api/relay/all_on` | Activer tous (proxy) |
| POST | `/api/relay/all_off` | Désactiver tous (proxy) |
| GET | `/api/config/endpoint` | Récupérer l'endpoint configuré |
| POST | `/api/config/endpoint` | Configurer l'endpoint |

## 🌟 Fonctionnalités

### Backend
- ✅ Contrôle direct GPIO Raspberry Pi
- ✅ Support relais actifs bas/haut
- ✅ Validation avec Pydantic
- ✅ Documentation auto (Swagger)
- ✅ Cleanup GPIO automatique

### Proxy
- ✅ Configuration dynamique endpoint
- ✅ Cache d'état local
- ✅ Type-safety avec Zod
- ✅ Support dev/prod avec Vite
- ✅ Logs des requêtes API

### Frontend
- ✅ Interface moderne et responsive
- ✅ Thème clair/sombre
- ✅ Auto-refresh configurable
- ✅ Status de connexion en temps réel
- ✅ Contrôle individuel et global
- ✅ Configuration endpoint en live

## 🎨 Aperçu Interface

L'interface web comprend :

1. **Header** : Nom de l'app + status connexion + toggle thème
2. **Panneau Configuration** : Endpoint API + test connexion
3. **Contrôle Maître** : Boutons pour tout activer/désactiver
4. **Cartes Relais** : Une carte par relais avec :
   - Nom du relais
   - GPIO associé
   - État actuel (ON/OFF)
   - Switch de contrôle
   - Dernière mise à jour

## 🚀 Déploiement

### Option 1 : Tout sur Raspberry Pi
```bash
npm run build
npm start
# Accès : http://IP_RASPBERRY:5000
```

### Option 2 : Frontend sur Vercel
```bash
vercel --prod
# Configurer l'endpoint vers http://IP_RASPBERRY:5000
```

### Option 3 : Architecture distribuée
- Raspberry Pi : GPIO API uniquement
- VPS : Proxy server
- Vercel : Frontend

Voir **DEPLOYMENT.md** pour les détails !

## 🔒 Sécurité (Production)

Pour un usage en production :

1. **HTTPS** : Utilisez Nginx + Let's Encrypt
2. **Authentification** : Ajoutez JWT ou Basic Auth
3. **Firewall** : Limitez les ports ouverts
4. **VPN** : Utilisez Tailscale pour accès sécurisé
5. **Rate Limiting** : Limitez les requêtes API

Voir **DEPLOYMENT.md** section Sécurité !

## 🧪 Test Rapide

```bash
# Test API GPIO
curl http://localhost:8000/

# Test contrôle relais
curl -X POST http://localhost:8000/relay \
  -H "Content-Type: application/json" \
  -d '{"gpio": 17, "state": "on"}'

# Test proxy
curl http://localhost:5000/api/status
```

## 📚 Documentation Complète

Pour plus de détails, consultez :

- **README.md** : Guide complet
- **QUICKSTART.md** : Démarrage rapide
- **DEPLOYMENT.md** : Déploiement production
- **ARCHITECTURE.md** : Architecture technique

## ❓ Besoin d'Aide ?

- 📖 Consultez les docs ci-dessus
- 🐛 Ouvrez une issue sur GitHub
- 💬 Regardez les issues existantes

## 🎉 Résumé

Le projet est **déjà organisé** et prêt à l'emploi avec :

✅ **Serveur REST API** pour GPIO Raspberry Pi (BGPIO.py)
✅ **Frontend déployable** n'importe où (client/)
✅ **Cohérence** via schémas partagés (shared/)
✅ **Tutoriel complet** (4 fichiers de documentation)

**Prêt à démarrer ?** Suivez **QUICKSTART.md** ! 🚀

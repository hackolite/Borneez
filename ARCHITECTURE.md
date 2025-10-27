# Architecture Borneez

## Vue d'ensemble du système

```
┌─────────────────────────────────────────────────────────────────┐
│                      FRONTEND (React + TypeScript)               │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Dashboard   │  │    Theme     │  │   API Config Panel   │  │
│  │    Page      │  │   Toggle     │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              React Query (État global)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Déployable : Vercel, Netlify, GitHub Pages, ou serveur local  │
│  Port Dev : 5173 (Vite) | Prod : servi via proxy               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTP REST API
                         │ (JSON)
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                PROXY SERVER (Express + TypeScript)              │
│                                                                  │
│  ┌──────────────────┐  ┌────────────────┐  ┌─────────────────┐ │
│  │   Routes API     │  │   Storage      │  │   Vite Setup    │ │
│  │                  │  │   (MemStore)   │  │   (Dev/Prod)    │ │
│  │  /api/status     │  │                │  │                 │ │
│  │  /api/relays     │  │ - API Endpoint │  │ - Dev: HMR      │ │
│  │  /api/relay      │  │ - Relays State │  │ - Prod: Static  │ │
│  │  /api/config     │  │                │  │                 │ │
│  └──────────────────┘  └────────────────┘  └─────────────────┘ │
│                                                                  │
│  Rôle : Proxy, Configuration, Cache d'état                      │
│  Port : 5000 (configurable via PORT env var)                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTP REST API
                         │ (JSON)
                         │
┌────────────────────────▼────────────────────────────────────────┐
│              GPIO CONTROLLER (FastAPI + Python)                 │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    FastAPI Routes                         │  │
│  │                                                           │  │
│  │  GET  /           → Status API + liste des pins          │  │
│  │  POST /relay      → Contrôle un relais                   │  │
│  │  POST /relay/all_on  → Active tous les relais            │  │
│  │  POST /relay/all_off → Désactive tous les relais         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              RelayController (Python Class)               │  │
│  │                                                           │  │
│  │  - Gestion des GPIO (BCM mode)                           │  │
│  │  - Support actif bas/haut                                │  │
│  │  - Initialisation safe des pins                          │  │
│  │  - Cleanup automatique au shutdown                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Port : 8000 (configurable) | Doit tourner sur Raspberry Pi    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ RPi.GPIO Library
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                    RASPBERRY PI GPIO HARDWARE                    │
│                                                                  │
│  GPIO 17 ──────► Relay Module IN1 ──► NO/NC/COM                 │
│  GPIO 27 ──────► Relay Module IN2 ──► NO/NC/COM                 │
│  GPIO 22 ──────► Relay Module IN3 ──► NO/NC/COM                 │
│  GPIO 23 ──────► Relay Module IN4 ──► NO/NC/COM                 │
│                                                                  │
│  Note : Les GPIO sont configurables dans BGPIO.py               │
└──────────────────────────────────────────────────────────────────┘
```

## Flux de données

### Activation d'un relais

```
1. User clicks relay switch in UI
                ↓
2. Frontend sends POST /api/relay
   Body: { gpio: 17, state: "on" }
                ↓
3. Proxy validates with Zod schema
                ↓
4. Proxy forwards to GPIO Controller
   POST http://ENDPOINT:8000/relay
                ↓
5. FastAPI validates with Pydantic
                ↓
6. RelayController.control(17, "on")
                ↓
7. RPi.GPIO.output(17, GPIO.LOW)  # Si active_low=True
                ↓
8. Hardware relay activates
                ↓
9. Response bubbles back to frontend
                ↓
10. UI updates relay state
    + Cache local mis à jour
```

### Configuration de l'endpoint

```
1. User enters endpoint URL in config panel
   e.g., "http://192.168.1.100:8000"
                ↓
2. Frontend saves to localStorage
                ↓
3. Frontend sends POST /api/config/endpoint
                ↓
4. Proxy saves to MemStorage
                ↓
5. User clicks "Test Connection"
                ↓
6. Frontend sends GET /api/status
                ↓
7. Proxy calls GET ENDPOINT/
                ↓
8. GPIO Controller responds with pins config
                ↓
9. Connection status updates in UI
```

## Schémas partagés (Type Safety)

```
┌─────────────────────────────────────┐
│      shared/schema.ts (Zod)         │
│                                     │
│  - relaySchema                      │
│  - relayCommandSchema               │
│  - apiConfigSchema                  │
│                                     │
│  Utilisé par :                      │
│  ✓ Frontend (validation + types)   │
│  ✓ Proxy (validation runtime)      │
└─────────────────────────────────────┘
```

## Modèles de déploiement

### Déploiement 1 : Tout local (1 machine)

```
┌────────────────────────────────┐
│       Raspberry Pi             │
│                                │
│  localhost:8000 → GPIO API     │
│  localhost:5000 → Proxy + UI   │
│                                │
│  Access: http://RPI_IP:5000    │
└────────────────────────────────┘
```

### Déploiement 2 : Frontend distant

```
┌─────────────────┐              ┌──────────────────┐
│  Raspberry Pi   │              │  Vercel/Netlify  │
│                 │              │                  │
│  :8000 GPIO API │◄─────────────┤  Frontend (SPA)  │
│  :5000 Proxy    │   REST API   │                  │
└─────────────────┘              └──────────────────┘
                                         │
                                    Accessible
                                   de partout
```

### Déploiement 3 : Architecture distribuée

```
┌──────────────┐    ┌────────────┐    ┌─────────────┐
│ Raspberry Pi │    │  VPS Cloud │    │   Vercel    │
│              │    │            │    │             │
│ :8000 GPIO   │◄───┤:5000 Proxy │◄───┤  Frontend   │
│              │SSH │            │REST│             │
│              │    │            │    │             │
└──────────────┘    └────────────┘    └─────────────┘
   Local only       Public HTTPS      Global CDN
```

## Technologies utilisées

### Backend (GPIO Controller)
- **FastAPI** : Framework Python moderne pour API REST
- **Pydantic** : Validation de données
- **RPi.GPIO** : Contrôle des GPIO Raspberry Pi
- **Uvicorn** : Serveur ASGI

### Middleware (Proxy Server)
- **Express** : Framework Node.js
- **TypeScript** : Typage statique
- **Zod** : Validation de schémas
- **Vite** : Build tool pour dev/prod

### Frontend
- **React 18** : Library UI
- **TypeScript** : Typage statique
- **TanStack Query** : Gestion d'état serveur
- **Wouter** : Routing léger
- **shadcn/ui** : Composants UI
- **Tailwind CSS** : Styling
- **Vite** : Dev server & bundler

## Points de sécurité

1. **Validation des données** à tous les niveaux :
   - Frontend : Zod schemas
   - Proxy : Zod schemas
   - GPIO API : Pydantic models

2. **Pas d'exposition directe** des GPIO au frontend

3. **Configuration dynamique** : L'endpoint peut être changé sans redéployer

4. **Gestion des erreurs** à chaque couche

5. **Pour production** :
   - Ajouter HTTPS (Nginx + Let's Encrypt)
   - Ajouter authentification (JWT, OAuth, ou Basic Auth)
   - Utiliser un firewall
   - Limiter les rate limits

## Performance

- **Frontend** : Build optimisé avec code splitting
- **Proxy** : Cache en mémoire de l'état des relais
- **GPIO API** : Opérations GPIO rapides (< 10ms)
- **Latence totale** : ~50-200ms pour une opération complète
  (dépend du réseau entre les composants)

## Extensibilité

Le système peut facilement être étendu pour :

- ✅ Ajouter plus de relais (modifier BGPIO.py)
- ✅ Ajouter d'autres types de GPIO (PWM, servos, etc.)
- ✅ Ajouter une base de données (Drizzle ORM déjà configuré)
- ✅ Ajouter des utilisateurs et permissions
- ✅ Ajouter des planifications (cron jobs)
- ✅ Ajouter des webhooks ou notifications
- ✅ Ajouter un historique des actions
- ✅ Intégrer avec Home Assistant, Alexa, etc.

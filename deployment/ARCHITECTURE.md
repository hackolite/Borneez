# Architecture de Déploiement Production

## Avec Reverse Proxy (Recommandé)

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet / LAN                        │
└────────────────────────────┬────────────────────────────────┘
                             │ Port 80/443 (HTTP/HTTPS)
                             │
┌────────────────────────────▼────────────────────────────────┐
│                   Nginx ou Caddy                             │
│                 (Reverse Proxy)                              │
│  - Écoute sur port 80 (HTTP standard)                       │
│  - Optionnel: HTTPS sur port 443                            │
│  - Gestion SSL/TLS automatique                              │
│  - Headers de sécurité                                       │
└────────────────────────────┬────────────────────────────────┘
                             │ localhost:3000
                             │
┌────────────────────────────▼────────────────────────────────┐
│            Borneez Proxy Server (Express)                    │
│                    Port 3000                                 │
│  - Gestion de la configuration                               │
│  - Cache de l'état des relais                               │
│  - Proxy des requêtes vers GPIO                             │
│  - Service du frontend React                                │
└────────────────────────────┬────────────────────────────────┘
                             │ localhost:8000
                             │
┌────────────────────────────▼────────────────────────────────┐
│          GPIO Controller (FastAPI/Python)                    │
│                    Port 8000                                 │
│  - Contrôle direct des GPIO Raspberry Pi                    │
│  - API REST pour les relais                                 │
│  - Documentation Swagger                                    │
└────────────────────────────┬────────────────────────────────┘
                             │
                   ┌─────────┴─────────┐
                   │                   │
              ┌────▼────┐         ┌────▼────┐
              │ GPIO 17 │   ...   │ GPIO 23 │
              │ Relais 1│         │ Relais 4│
              └─────────┘         └─────────┘
```

## Accès

**Utilisateur** → http://raspberrypi.local (Port 80)
             → Nginx/Caddy (Port 80)
             → Express Server (Port 3000)
             → GPIO Controller (Port 8000)
             → Hardware GPIO

## Sans Reverse Proxy (Simple)

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet / LAN                        │
└────────────────────────────┬────────────────────────────────┘
                             │ Port 3000
                             │
┌────────────────────────────▼────────────────────────────────┐
│            Borneez Proxy Server (Express)                    │
│                    Port 3000                                 │
│  - Gestion de la configuration                               │
│  - Cache de l'état des relais                               │
│  - Proxy des requêtes vers GPIO                             │
│  - Service du frontend React                                │
└────────────────────────────┬────────────────────────────────┘
                             │ localhost:8000
                             │
┌────────────────────────────▼────────────────────────────────┐
│          GPIO Controller (FastAPI/Python)                    │
│                    Port 8000                                 │
│  - Contrôle direct des GPIO Raspberry Pi                    │
│  - API REST pour les relais                                 │
│  - Documentation Swagger                                    │
└────────────────────────────┬────────────────────────────────┘
                             │
                   ┌─────────┴─────────┐
                   │                   │
              ┌────▼────┐         ┌────▼────┐
              │ GPIO 17 │   ...   │ GPIO 23 │
              │ Relais 1│         │ Relais 4│
              └─────────┘         └─────────┘
```

## Accès

**Utilisateur** → http://raspberrypi.local:3000 (Port 3000)
             → Express Server (Port 3000)
             → GPIO Controller (Port 8000)
             → Hardware GPIO

## Services Systemd

```
┌─────────────────────────────────────────┐
│        Systemd (Gestionnaire)            │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────────────────────────────┐    │
│  │  borneez-gpio.service          │    │
│  │  → python3 BGPIO.py            │    │
│  │  → Port 8000                   │    │
│  │  → Démarrage automatique       │    │
│  │  → Redémarrage auto en cas     │    │
│  │    d'échec                     │    │
│  └────────────────────────────────┘    │
│               ▲                         │
│               │ Requires                │
│  ┌────────────┴───────────────────┐    │
│  │  borneez-server.service        │    │
│  │  → node dist/index.js          │    │
│  │  → Port 3000                   │    │
│  │  → Démarrage automatique       │    │
│  │  → Redémarrage auto en cas     │    │
│  │    d'échec                     │    │
│  └────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

## Flux de Données

1. **Requête Utilisateur** : `GET http://raspberrypi.local/api/relays`
2. **Nginx/Caddy** : Reçoit sur port 80, proxy vers localhost:3000
3. **Express Server** : Reçoit `/api/relays`, vérifie cache/config
4. **GPIO Controller** : Reçoit requête de Express, lit GPIO
5. **Réponse** : GPIO → Express → Nginx → Utilisateur

## Sécurité

### Avec Reverse Proxy
- ✅ Port 80/443 standard
- ✅ HTTPS possible (Let's Encrypt)
- ✅ Headers de sécurité
- ✅ Rate limiting possible
- ✅ Logs centralisés
- ✅ Application protégée

### Sans Reverse Proxy
- ⚠️  Port 3000 non-standard
- ⚠️  Pas de HTTPS natif
- ✅ Plus simple à configurer
- ✅ Moins de composants

## Avantages du Reverse Proxy

1. **Port Standard** : Port 80 (HTTP) / 443 (HTTPS)
2. **HTTPS Facile** : Let's Encrypt automatique (Caddy) ou simple (Nginx)
3. **Sécurité** : Headers, rate limiting, WAF possible
4. **Performance** : Cache statique, compression
5. **Flexibilité** : Load balancing, multiple backends possibles
6. **Standards** : Architecture production standard

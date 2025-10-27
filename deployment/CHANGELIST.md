# 📦 Nouveaux Fichiers de Déploiement

## ✅ Ce qui a été ajouté

### 1. Configuration Reverse Proxy

**`deployment/nginx/borneez.conf`** - Configuration Nginx pour reverse proxy
- Écoute sur le port 80 (HTTP standard)
- Proxy vers l'application Node.js sur port 3000
- Support WebSocket
- Headers de sécurité
- Configuration HTTPS commentée (à activer avec Let's Encrypt)

**`deployment/nginx/Caddyfile`** - Configuration Caddy pour reverse proxy
- Alternative à Nginx
- HTTPS automatique avec Let's Encrypt
- Configuration ultra-simple
- Idéal pour débutants

### 2. Services Systemd

**`deployment/systemd/borneez-gpio.service`** - Service pour le contrôleur GPIO
- Démarrage automatique au boot
- Redémarrage automatique en cas d'échec
- Logs dans journald
- Sécurité renforcée (NoNewPrivileges, PrivateTmp)

**`deployment/systemd/borneez-server.service`** - Service pour le serveur proxy
- Dépend du service GPIO
- Configuration via variables d'environnement
- Port 3000 (pas besoin de privilèges root)
- Redémarrage automatique

### 3. Scripts d'Installation

**`deployment/scripts/setup-production.sh`** - Script d'installation automatique
- Installation de toutes les dépendances
- Choix entre Nginx, Caddy ou aucun reverse proxy
- Configuration des services systemd
- Build de l'application
- Démarrage automatique
- Rapports détaillés

**`start-production.sh`** - Script de démarrage rapide en production
- Alternative au setup complet
- Démarre directement sur port 80 (avec sudo)
- Ou sur un autre port (sans sudo)
- Pas de services systemd (processus manuels)

### 4. Documentation

**`deployment/README.md`** - Guide complet de déploiement
- Instructions détaillées pour chaque méthode
- Configuration manuelle vs automatique
- Guide de dépannage
- Gestion des services
- Sécurité et HTTPS

**`QUICKSTART_PRODUCTION.md`** - Guide ultra-rapide
- Commandes essentielles
- Installation en 1 ligne
- Accès rapide
- Carte de référence

### 5. Mises à jour de la documentation

**`README.md`** - Ajout d'une section production
- Référence aux nouveaux scripts
- 3 méthodes de démarrage
- Liens vers la documentation détaillée

**`DEPLOYMENT.md`** - Mise à jour
- Référence au script d'installation automatique
- Architecture mise à jour avec reverse proxy

## 🎯 Usage

### Installation Automatique (Recommandé)
```bash
sudo deployment/scripts/setup-production.sh nginx
```

### Démarrage Manuel Rapide
```bash
sudo ./start-production.sh
```

### Installation Manuelle Complète
Voir `deployment/README.md`

## 📊 Structure créée

```
Borneez/
├── deployment/
│   ├── nginx/
│   │   ├── borneez.conf         # Config Nginx
│   │   └── Caddyfile            # Config Caddy
│   ├── systemd/
│   │   ├── borneez-gpio.service     # Service GPIO
│   │   └── borneez-server.service   # Service serveur
│   ├── scripts/
│   │   └── setup-production.sh      # Installation auto
│   └── README.md                    # Guide complet
├── start-production.sh              # Démarrage rapide
├── QUICKSTART_PRODUCTION.md         # Carte de référence
└── [fichiers mis à jour]
    ├── README.md
    └── DEPLOYMENT.md
```

## ✨ Avantages

1. **Port 80 standard** : Plus besoin de spécifier le port dans l'URL
2. **HTTPS facile** : Configuration Let's Encrypt prête à l'emploi
3. **Démarrage automatique** : Services systemd qui démarrent au boot
4. **Redémarrage automatique** : En cas de crash, les services redémarrent
5. **Sécurité** : Reverse proxy qui protège l'application
6. **Logs centralisés** : Tous les logs dans journald
7. **Installation en 1 commande** : Script automatique
8. **Flexibilité** : Nginx, Caddy ou aucun reverse proxy

## 🔧 Configuration Standard

- **Port 80** : Nginx/Caddy (accessible sans spécifier le port)
- **Port 3000** : Application Node.js (interne)
- **Port 8000** : API GPIO (interne)

## 📝 Notes importantes

- Le port 80 nécessite sudo ou un reverse proxy
- Les services systemd s'exécutent avec l'utilisateur courant (pas root pour plus de sécurité)
- Le reverse proxy peut être configuré pour HTTPS
- Les fichiers service sont adaptables (chemins, utilisateur)
- Tout est prêt pour la production selon les standards Linux

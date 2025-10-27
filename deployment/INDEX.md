# 📚 Index de Documentation - Déploiement Borneez

Bienvenue dans la documentation de déploiement de Borneez ! Ce fichier vous guide vers la bonne documentation selon vos besoins.

## 🚀 Je veux démarrer rapidement

### En développement (sans hardware GPIO)
→ Consultez [README.md](../README.md#-démarrage-rapide-recommandé) section "Démarrage Rapide"

Commande : `./start-dev.sh` ou `start-dev.bat`

### En production (avec Raspberry Pi)
→ Consultez [QUICKSTART_PRODUCTION.md](../QUICKSTART_PRODUCTION.md)

Commande : `sudo deployment/scripts/setup-production.sh nginx`

## 📖 Je veux comprendre l'architecture

→ Consultez [deployment/ARCHITECTURE.md](ARCHITECTURE.md)

Ce document explique :
- L'architecture avec et sans reverse proxy
- Le flux de données
- Les avantages de chaque approche
- Les services systemd

## 🔧 Je veux installer en production

### Installation automatique (recommandé)
→ Consultez [deployment/README.md](README.md#-installation-rapide-recommandé)

Le script d'installation configure tout automatiquement :
```bash
sudo deployment/scripts/setup-production.sh nginx
```

### Installation manuelle étape par étape
→ Consultez [deployment/README.md](README.md#-installation-manuelle-avancé)

Pour ceux qui veulent comprendre chaque étape ou personnaliser l'installation.

### Configuration avancée
→ Consultez [DEPLOYMENT.md](../DEPLOYMENT.md)

Guide détaillé avec différents scénarios de déploiement.

## 🌐 Je veux configurer un reverse proxy

### Nginx
→ Fichier : [deployment/nginx/borneez.conf](nginx/borneez.conf)
→ Documentation : [deployment/README.md](README.md#option-1--avec-nginx-recommandé)

### Caddy
→ Fichier : [deployment/nginx/Caddyfile](nginx/Caddyfile)
→ Documentation : [deployment/README.md](README.md#option-2--avec-caddy-https-automatique)

## 🔒 Je veux activer HTTPS

### Avec Nginx + Let's Encrypt
→ Consultez [deployment/README.md](README.md#avec-nginx--lets-encrypt)

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com
```

### Avec Caddy (automatique)
→ Consultez [deployment/README.md](README.md#avec-caddy)

Caddy gère HTTPS automatiquement, il suffit de mettre votre domaine dans la config.

## 🛠️ Je veux gérer les services

### Commandes essentielles
→ Consultez [deployment/README.md](README.md#-gestion-des-services)

```bash
# Logs
sudo journalctl -u borneez-gpio -f

# Redémarrer
sudo systemctl restart borneez-server

# Statut
sudo systemctl status borneez-gpio
```

### Redémarrage après mise à jour du code
→ Consultez [deployment/README.md](README.md#redémarrage-après-modification-du-code)

## 🐛 J'ai un problème

### Dépannage général
→ Consultez [deployment/README.md](README.md#-dépannage)

### Problèmes spécifiques
→ Consultez [README.md](../README.md#-dépannage) pour les problèmes de base
→ Consultez [DEPLOYMENT.md](../DEPLOYMENT.md#-dépannage) pour les problèmes de déploiement

## 📝 Je veux savoir ce qui a été ajouté

→ Consultez [deployment/CHANGELIST.md](CHANGELIST.md)

Liste complète de tous les nouveaux fichiers et fonctionnalités.

## ✅ Je veux valider mon installation

→ Script de validation : [deployment/scripts/validate-deployment.sh](scripts/validate-deployment.sh)

```bash
bash deployment/scripts/validate-deployment.sh
```

Ce script vérifie que tous les fichiers sont présents et valides.

## 🗂️ Structure des Fichiers

```
Borneez/
├── deployment/                          ← Tout pour la production
│   ├── README.md                        ← Guide complet de déploiement
│   ├── ARCHITECTURE.md                  ← Diagrammes d'architecture
│   ├── CHANGELIST.md                    ← Liste des nouveautés
│   ├── INDEX.md                         ← Ce fichier !
│   ├── nginx/
│   │   ├── borneez.conf                 ← Config Nginx
│   │   └── Caddyfile                    ← Config Caddy
│   ├── systemd/
│   │   ├── borneez-gpio.service         ← Service GPIO
│   │   └── borneez-server.service       ← Service serveur
│   └── scripts/
│       ├── setup-production.sh          ← Installation auto
│       └── validate-deployment.sh       ← Validation
├── start-production.sh                  ← Démarrage rapide prod
├── QUICKSTART_PRODUCTION.md             ← Guide ultra-rapide
├── README.md                            ← Documentation principale
└── DEPLOYMENT.md                        ← Guide de déploiement détaillé
```

## 🎯 Cas d'Usage Fréquents

### "Je veux installer sur mon Raspberry Pi pour la première fois"
1. Clonez le repo : `git clone https://github.com/hackolite/Borneez.git`
2. Allez dans le dossier : `cd Borneez`
3. Lancez l'installation : `sudo deployment/scripts/setup-production.sh nginx`
4. C'est tout ! Accédez à `http://raspberrypi.local`

### "Je veux tester en local sans hardware"
1. Clonez le repo
2. Lancez : `./start-dev.sh` (Linux/Mac) ou `start-dev.bat` (Windows)
3. Ouvrez : `http://localhost:5000`

### "Je veux mettre à jour l'application"
1. `cd Borneez`
2. `git pull`
3. `npm install`
4. `npm run build`
5. `sudo systemctl restart borneez-gpio borneez-server`

### "Je veux activer HTTPS"
**Avec Nginx :**
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com
```

**Avec Caddy :**
```bash
sudo nano /etc/caddy/Caddyfile  # Remplacer :80 par votre domaine
sudo systemctl restart caddy
```

### "Je veux changer de port"
Éditez `/etc/systemd/system/borneez-server.service` :
```ini
Environment="PORT=8080"  # Au lieu de 3000
```
Puis : `sudo systemctl daemon-reload && sudo systemctl restart borneez-server`

### "Je veux voir les logs"
```bash
# Logs en temps réel
sudo journalctl -u borneez-gpio -f
sudo journalctl -u borneez-server -f

# 100 dernières lignes
sudo journalctl -u borneez-gpio -n 100
```

## 🆘 Besoin d'Aide ?

1. **Documentation officielle** : Commencez par [README.md](../README.md)
2. **Guides de déploiement** : [deployment/README.md](README.md)
3. **Dépannage** : Section dépannage dans chaque document
4. **Issues GitHub** : https://github.com/hackolite/Borneez/issues
5. **Validateur** : `bash deployment/scripts/validate-deployment.sh`

## 📌 Liens Rapides

- **Installation rapide** : [QUICKSTART_PRODUCTION.md](../QUICKSTART_PRODUCTION.md)
- **Architecture** : [deployment/ARCHITECTURE.md](ARCHITECTURE.md)
- **Guide complet** : [deployment/README.md](README.md)
- **Configurations Nginx** : [deployment/nginx/borneez.conf](nginx/borneez.conf)
- **Configurations Caddy** : [deployment/nginx/Caddyfile](nginx/Caddyfile)
- **Services systemd** : [deployment/systemd/](systemd/)
- **Scripts** : [deployment/scripts/](scripts/)

---

**💡 Conseil** : Commencez par le [QUICKSTART_PRODUCTION.md](../QUICKSTART_PRODUCTION.md) si vous voulez juste que ça marche rapidement, puis explorez la documentation détaillée si vous voulez comprendre ou personnaliser.

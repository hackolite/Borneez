# Scripts de Déploiement Borneez

Ce répertoire contient des scripts utilitaires pour le déploiement et la gestion de Borneez en production.

## 📜 Scripts Disponibles

### 1. setup-production.sh

Script d'installation complète en production.

**Usage :**
```bash
sudo ./setup-production.sh [nginx|caddy|none]
```

**Fonctionnalités :**
- ✅ Installe toutes les dépendances système (Python, Node.js, Avahi)
- ✅ Configure et installe le reverse proxy (Nginx ou Caddy)
- ✅ Build l'application
- ✅ Configure les services systemd
- ✅ Active et démarre les services automatiquement

**Exemples :**
```bash
# Installation avec Nginx (recommandé)
sudo ./setup-production.sh nginx

# Installation avec Caddy (HTTPS automatique)
sudo ./setup-production.sh caddy

# Installation sans reverse proxy (port 3000)
sudo ./setup-production.sh none
```

---

### 2. enable-autostart.sh

Script simple pour activer/désactiver le démarrage automatique au boot.

**Usage :**
```bash
sudo ./enable-autostart.sh [enable|disable|status]
```

**Fonctionnalités :**
- ✅ Configure les services systemd s'ils n'existent pas
- ✅ Active ou désactive le démarrage automatique
- ✅ Démarre/arrête les services immédiatement
- ✅ Affiche le statut détaillé des services

**Exemples :**
```bash
# Activer le démarrage automatique
sudo ./enable-autostart.sh enable

# Vérifier le statut
sudo ./enable-autostart.sh status

# Désactiver le démarrage automatique
sudo ./enable-autostart.sh disable
```

**Quand l'utiliser :**
- Vous avez déjà une installation fonctionnelle
- Vous voulez juste activer/désactiver le démarrage au boot
- Vous ne voulez pas réinstaller tout le système

---

### 3. validate-deployment.sh

Script de validation du déploiement.

**Usage :**
```bash
./validate-deployment.sh
```

**Fonctionnalités :**
- ✅ Vérifie que tous les services sont actifs
- ✅ Teste la connectivité des APIs
- ✅ Valide la configuration
- ✅ Affiche un rapport détaillé

---

## 🔄 Workflows Communs

### Premier déploiement complet

```bash
# 1. Installation complète
sudo deployment/scripts/setup-production.sh nginx

# 2. Validation
deployment/scripts/validate-deployment.sh
```

### Activation du démarrage automatique uniquement

```bash
# Si vous avez déjà une installation fonctionnelle
sudo deployment/scripts/enable-autostart.sh enable
```

### Désactivation temporaire

```bash
# Désactiver le démarrage automatique sans désinstaller
sudo deployment/scripts/enable-autostart.sh disable
```

### Vérification de l'état

```bash
# Voir le statut détaillé
sudo deployment/scripts/enable-autostart.sh status

# Ou avec systemctl
sudo systemctl status borneez-gpio borneez-server
```

---

## 📋 Notes

- Tous les scripts nécessitent des privilèges sudo (sauf validate-deployment.sh)
- Les services systemd sont configurés pour redémarrer automatiquement en cas d'échec
- Les logs sont accessibles via `journalctl` :
  ```bash
  sudo journalctl -u borneez-gpio -f
  sudo journalctl -u borneez-server -f
  ```

## 🆘 Aide

Pour plus d'informations, consultez :
- [deployment/README.md](../README.md) - Guide de déploiement complet
- [README.md](../../README.md) - Documentation principale

# 🚀 Guide de Démarrage Rapide - Production

## Installation en 1 commande

```bash
# Avec Nginx (recommandé)
sudo deployment/scripts/setup-production.sh nginx
```

## Ou démarrage manuel rapide

```bash
# Démarrage simple sur port 80 (nécessite sudo)
sudo ./start-production.sh

# Ou sur un autre port (pas besoin de sudo)
PORT=3000 ./start-production.sh
```

## URLs d'accès

- **Application** : http://raspberrypi.local
- **API GPIO** : http://localhost:8000
- **Docs API** : http://localhost:8000/docs

## Commandes essentielles

```bash
# Voir les logs
sudo journalctl -u borneez-gpio -f
sudo journalctl -u borneez-server -f

# Redémarrer
sudo systemctl restart borneez-gpio
sudo systemctl restart borneez-server

# Arrêter
sudo systemctl stop borneez-gpio borneez-server

# Statut
sudo systemctl status borneez-gpio
sudo systemctl status borneez-server
```

## HTTPS avec Nginx

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com
```

## HTTPS avec Caddy

```bash
# Éditer /etc/caddy/Caddyfile et remplacer :80 par votre domaine
sudo nano /etc/caddy/Caddyfile
sudo systemctl restart caddy
```

---

Pour plus de détails, voir [deployment/README.md](deployment/README.md)

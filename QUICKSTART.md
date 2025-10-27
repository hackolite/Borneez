# Guide de Démarrage Rapide

## 🚀 Démarrage en 5 minutes

Ce guide vous permet de tester Borneez rapidement en mode développement.

## Prérequis

- Node.js 18+ installé
- Python 3.8+ installé (avec pip)
- Raspberry Pi avec GPIO disponibles (ou simulateur pour tester)

## Étape 1 : Installation (2 min)

```bash
# Cloner le projet
git clone https://github.com/hackolite/Borneez.git
cd Borneez

# Installer les dépendances Node.js
npm install

# Installer les dépendances Python
pip3 install fastapi uvicorn pydantic
```

**Note :** Sur Raspberry Pi, installez aussi :
```bash
sudo apt-get install python3-rpi.gpio
```

## Étape 2 : Configuration des GPIO (1 min)

Ouvrez `BGPIO.py` et vérifiez la ligne 46 :

```python
# Adapter ces GPIO selon votre câblage
relais = RelayController([17, 27, 22, 23])
```

**Schéma de connexion classique :**
```
Relay Module    Raspberry Pi
VCC       ───→  5V (Pin 2 ou 4)
GND       ───→  GND (Pin 6, 9, 14, 20, 25, 30, 34, 39)
IN1       ───→  GPIO 17 (Pin 11)
IN2       ───→  GPIO 27 (Pin 13)
IN3       ───→  GPIO 22 (Pin 15)
IN4       ───→  GPIO 23 (Pin 16)
```

## Étape 3 : Lancement (2 min)

### Terminal 1 : Démarrer le contrôleur GPIO

```bash
# Sur Raspberry Pi
cd Borneez
python3 BGPIO.py
```

Vous devriez voir :
```
INFO:     Started server process [xxxxx]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Note :** Notez l'adresse IP de votre Raspberry Pi :
```bash
hostname -I
# Exemple de sortie : 192.168.1.100
```

### Terminal 2 : Démarrer le serveur proxy + frontend

```bash
# Sur votre PC de développement (ou le Raspberry Pi)
cd Borneez
npm run dev
```

Vous devriez voir :
```
serving on port 5000
```

## Étape 4 : Configuration de l'interface (1 min)

1. **Ouvrir le navigateur :**
   ```
   http://localhost:5000
   ```
   
   Si vous êtes sur un autre PC que le Raspberry Pi :
   ```
   http://<IP_RASPBERRY>:5000
   ```

2. **Configurer l'endpoint API :**
   - Dans la section "API Configuration"
   - Entrez l'URL du contrôleur GPIO :
     ```
     http://192.168.1.100:8000
     ```
     (Remplacez par votre IP)
   
3. **Tester la connexion :**
   - Cliquez sur "Test Connection"
   - Vous devriez voir "Connected to relay controller with 4 relays"

4. **Sauvegarder :**
   - Cliquez sur "Save"

## Étape 5 : Utilisation 🎉

Votre dashboard est maintenant opérationnel !

### Contrôler un relais individuel
- Cliquez sur le switch d'une carte de relais
- Le relais devrait changer d'état

### Contrôler tous les relais
- Utilisez les boutons "Turn All On" ou "Turn All Off"
- Tous les relais s'activent/désactivent ensemble

### Options avancées
- **Auto Refresh** : Active le rafraîchissement automatique de l'état
- **Refresh Interval** : Configure l'intervalle (5000 ms par défaut)
- **Theme Toggle** : Basculer entre mode clair et sombre

## 🧪 Test sans GPIO (Simulation)

Si vous n'avez pas de Raspberry Pi, vous pouvez quand même tester l'interface :

1. **Modifier BGPIO.py pour simuler les GPIO :**

Remplacez les lignes 2-8 par :
```python
# Mode simulation (sans hardware)
class GPIO:
    BCM = "BCM"
    OUT = "OUT"
    LOW = 0
    HIGH = 1
    
    @staticmethod
    def setmode(mode): pass
    
    @staticmethod
    def setwarnings(state): pass
    
    @staticmethod
    def setup(pin, mode): pass
    
    @staticmethod
    def output(pin, state):
        print(f"GPIO {pin} -> {'ON' if state == GPIO.LOW else 'OFF'}")
    
    @staticmethod
    def cleanup(): pass
```

2. **Lancer normalement :**
```bash
python3 BGPIO.py
```

Les actions s'afficheront dans la console au lieu de contrôler des GPIO réels.

## 📱 Accès depuis un autre appareil (smartphone, tablette)

1. **Vérifier que les appareils sont sur le même réseau WiFi**

2. **Trouver l'IP du Raspberry Pi :**
```bash
hostname -I
```

3. **Depuis l'autre appareil, accédez à :**
```
http://192.168.1.100:5000
```
(Remplacez par votre IP)

4. **Configurer l'endpoint** dans l'interface vers la même IP

## 🔍 Vérification du bon fonctionnement

### Test 1 : API GPIO fonctionne
```bash
curl http://localhost:8000/
```

Réponse attendue :
```json
{
  "message": "API relais opérationnelle ✅",
  "pins": [17, 27, 22, 23]
}
```

### Test 2 : Proxy fonctionne
```bash
curl http://localhost:5000/api/status
```

Réponse attendue (si endpoint configuré) :
```json
{
  "connected": true,
  "message": "API relais opérationnelle ✅",
  "pins": [17, 27, 22, 23]
}
```

### Test 3 : Contrôle manuel d'un relais
```bash
curl -X POST http://localhost:8000/relay \
  -H "Content-Type: application/json" \
  -d '{"gpio": 17, "state": "on"}'
```

Le relais sur GPIO 17 devrait s'activer.

## ❓ Problèmes courants

### "Connection Failed" dans l'interface

**Causes :**
- Le contrôleur GPIO n'est pas démarré
- Mauvaise URL configurée
- Firewall bloque le port 8000

**Solutions :**
```bash
# Vérifier que le contrôleur tourne
curl http://localhost:8000/

# Vérifier les ports ouverts
sudo netstat -tlnp | grep -E '5000|8000'

# Tester avec l'IP exacte
curl http://192.168.1.100:8000/
```

### "EADDRINUSE: address already in use"

**Solution :**
```bash
# Trouver le processus sur le port
sudo lsof -i :5000

# Le tuer
kill -9 <PID>
```

### Relais ne réagissent pas

**Vérifications :**
1. Le module de relais est-il alimenté (VCC et GND) ?
2. Les GPIO sont-ils correctement connectés ?
3. Le module est-il actif bas ou actif haut ?

Pour module actif haut, modifiez `BGPIO.py` ligne 46 :
```python
relais = RelayController([17, 27, 22, 23], active_low=False)
```

## 📚 Prochaines étapes

- ✅ Ça fonctionne ? Consultez [README.md](README.md) pour plus de détails
- 🚀 Prêt pour la production ? Voir [DEPLOYMENT.md](DEPLOYMENT.md)
- 🔒 Besoin de sécurité ? Voir la section Sécurité dans DEPLOYMENT.md
- 🤝 Envie de contribuer ? Ouvrez une issue ou une PR !

## 🆘 Support

Besoin d'aide ?
- 📖 Consultez le [README.md](README.md) complet
- 🐛 Ouvrez une issue sur GitHub
- 💬 Regardez les issues existantes

---

**Bon démarrage avec Borneez ! 🎉**

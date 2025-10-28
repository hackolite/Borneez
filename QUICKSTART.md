# 🚀 Guide de Démarrage Rapide - Borneez

Ce guide vous permet de démarrer le système de contrôle de relais en moins de 5 minutes.

## 🎯 Pour les Développeurs (Sans Raspberry Pi)

### Prérequis
- Node.js 18+ ([Télécharger](https://nodejs.org/))
- Python 3.8+ ([Télécharger](https://www.python.org/))

### Installation et Démarrage

1. **Cloner le projet**
   ```bash
   git clone https://github.com/hackolite/Borneez.git
   cd Borneez
   ```

2. **Installer les dépendances**
   ```bash
   npm install
   pip install fastapi uvicorn pydantic
   ```

3. **Démarrer le système complet**
   
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

4. **Configurer l'interface**
   - Ouvrez http://localhost:5000
   - Cliquez sur "API Configuration"
   - Entrez : `http://localhost:8000`
   - Cliquez "Test Connection" puis "Save Configuration"

5. **🎉 C'est tout !** Vous pouvez maintenant contrôler les relais simulés depuis l'interface.

## 🍓 Pour Raspberry Pi (Contrôle GPIO Réel)

### Prérequis Supplémentaires
- Raspberry Pi avec GPIO
- Relais connectés aux GPIO (par défaut : 17, 27, 22, 23)

### Installation et Démarrage

1. **Sur le Raspberry Pi, installer les dépendances GPIO**
   ```bash
   sudo apt-get update
   sudo apt-get install python3-rpi.gpio
   pip3 install fastapi uvicorn pydantic
   npm install
   ```

2. **Configurer les GPIO**
   
   Éditez `BGPIO.py` ligne 46 pour correspondre à votre câblage :
   ```python
   relais = RelayController([17, 27, 22, 23])  # Vos GPIO ici
   ```

3. **Démarrer le système**
   ```bash
   ./start-rpi.sh
   ```

4. **Accéder depuis un autre PC**
   - Ouvrez http://IP_RASPBERRY:5000
   - Configurez l'endpoint : `http://IP_RASPBERRY:8000`
   - Contrôlez vos relais !

## 🔧 Commandes Utiles

| Commande | Description |
|----------|-------------|
| `npm run dev:full` | Démarre frontend + backend |
| `npm run dev` | Démarre uniquement le frontend |
| `npm run dev:backend` | Démarre uniquement le backend |
| `python3 BGPIO.py` | Démarre le backend GPIO réel |

## 📖 Documentation Complète

Consultez [README.md](README.md) pour plus d'informations sur :
- L'architecture du système
- La documentation API
- Le déploiement en production
- Le dépannage

## 💡 Astuces

- **Mode Mock** : Parfait pour développer/tester sans Raspberry Pi
- **Auto-refresh** : Activez dans les paramètres pour voir les changements en temps réel
- **Documentation API** : Disponible sur http://localhost:8000/docs
- **Thème** : Basculez entre clair/sombre avec le bouton en haut à droite

## 🐛 Problèmes Courants

### Le frontend ne se connecte pas au backend
- Vérifiez que le backend est démarré (`http://localhost:8000`)
- Vérifiez l'endpoint configuré dans "API Configuration"
- Vérifiez les logs dans la console

### "Module not found" erreurs
```bash
npm install
pip install fastapi uvicorn pydantic
```

### Les ports sont déjà utilisés
- Backend (8000) ou Frontend (5000) déjà en cours
- Arrêtez les processus existants ou changez les ports

## 📞 Support

Pour plus d'aide, consultez la [documentation complète](README.md) ou ouvrez une issue sur GitHub.

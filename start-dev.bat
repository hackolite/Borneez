@echo off
title Borneez - Relay Control System (Dev Mode)
color 0B

echo ========================================================
echo     Borneez - Relay Control System
echo           Mode DEVELOPPEMENT (Mock GPIO)
echo ========================================================
echo.

REM Vérifier Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Node.js n'est pas installe!
    echo Installez Node.js depuis https://nodejs.org/
    pause
    exit /b 1
)

REM Vérifier Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe!
    echo Installez Python depuis https://www.python.org/
    pause
    exit /b 1
)

REM Installer les dépendances Node.js si nécessaire
if not exist "node_modules" (
    echo [INFO] Installation des dependances Node.js...
    call npm install
)

REM Installer les dépendances Python si nécessaire
echo [INFO] Verification des dependances Python...
python -c "import fastapi, uvicorn, pydantic" 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Installation des dependances Python...
    pip install fastapi uvicorn pydantic
)

echo.
echo [OK] Toutes les dependances sont pretes!
echo.

REM Créer un fichier pour gérer les processus
echo @echo off > stop-services.bat
echo taskkill /F /IM python.exe /T 2^>nul >> stop-services.bat
echo taskkill /F /IM node.exe /T 2^>nul >> stop-services.bat
echo del stop-services.bat >> stop-services.bat

echo ========================================================
echo   Demarrage du Backend GPIO (Mock Mode)
echo ========================================================
start "Backend GPIO (Mock)" cmd /k python BGPIO_mock.py

REM Attendre que le backend soit prêt
timeout /t 3 /nobreak >nul

echo.
echo ========================================================
echo   Demarrage du Frontend + Proxy Server
echo ========================================================
start "Frontend + Proxy" cmd /k npm run dev

REM Attendre que le frontend soit prêt
timeout /t 5 /nobreak >nul

echo.
echo ========================================================
echo                SYSTEME DEMARRE
echo ========================================================
echo.
echo Frontend disponible sur:    http://localhost:5000
echo Backend GPIO (Mock) sur:    http://localhost:8000
echo Documentation API:          http://localhost:8000/docs
echo.
echo Configuration requise:
echo   1. Ouvrez http://localhost:5000
echo   2. Cliquez sur 'API Configuration'
echo   3. Entrez l'endpoint: http://localhost:8000
echo   4. Cliquez sur 'Test Connection' puis 'Save Configuration'
echo.
echo Mode Mock active - Aucun materiel GPIO requis!
echo.
echo Appuyez sur une touche pour arreter tous les services...
pause >nul

REM Arrêter tous les services
call stop-services.bat

echo.
echo Services arretes.
pause

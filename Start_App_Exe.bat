@echo off
echo ===================================================
echo    DEMARRAGE DU GESTIONNAIRE DE TEMPLATES BROTHER
echo    (VERSION EXECUTABLE)
echo ===================================================
echo.
echo Lancement du serveur...
start /b template-manager-td4t.exe
echo.
echo Attente du demarrage...
timeout /t 2 >nul
echo.
echo Ouverture du navigateur...
start http://localhost:3000
echo.
echo ===================================================
echo    APPLICATION LANCEE !
echo    Ne fermez pas cette fenetre tant que vous l'utilisez.
echo ===================================================
pause

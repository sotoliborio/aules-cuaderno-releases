@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File actualizar.ps1
pause

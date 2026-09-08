@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0recover-wayback-images.ps1"
echo.
pause

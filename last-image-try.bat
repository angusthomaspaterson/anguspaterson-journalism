@echo off
cd /d "%~dp0"
REM Last attempt at the missing photographs. Searches, sweeps the image
REM folders, and downloads two article pages. Publishes nothing.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0last-image-try.ps1"
echo.
pause

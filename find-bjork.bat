@echo off
cd /d "%~dp0"
REM Searches for the Bjork review and downloads whatever it finds.
REM Publishes nothing.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find-bjork.ps1"
echo.
pause

@echo off
cd /d "%~dp0"
REM Downloads 12 archived article pages into archived-pages\ for Claude to read.
REM No images are fetched and nothing is published.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0get-archived-pages.ps1"
echo.
pause

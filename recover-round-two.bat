@echo off
cd /d "%~dp0"
REM Downloads 23 photographs into recovered-external\ and writes three
REM wayback-*.csv files for Claude to read. Publishes nothing.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0recover-round-two.ps1"
echo.
pause

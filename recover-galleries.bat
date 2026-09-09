@echo off
cd /d "%~dp0"
REM Downloads his own Sonar 2012 gallery photographs plus the two surviving
REM lead images, and sweeps for the rest of his albums. Publishes nothing.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0recover-galleries.ps1"
echo.
pause

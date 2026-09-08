@echo off
cd /d "%~dp0"
REM Fetches the Nine Inch Nails review pages and checks which missing
REM photographs the Wayback Machine actually holds. Publishes nothing.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find-the-review.ps1"
echo.
pause

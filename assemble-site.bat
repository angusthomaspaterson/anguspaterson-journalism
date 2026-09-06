@echo off
REM Double-click this to run assemble-site.ps1.
REM Windows blocks unsigned PowerShell scripts by default; -ExecutionPolicy Bypass
REM applies to this one run and changes no setting on the machine.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0assemble-site.ps1"
echo.
pause

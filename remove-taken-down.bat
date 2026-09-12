@echo off
REM Removes the Watergate Records piece from the repository.
REM Unzipping an update adds and overwrites files; it cannot delete one, so this
REM takes out the three folders that belonged to the page you asked to take down.
REM Skip it if you have already run it once: it does nothing the second time.
REM
REM If Windows blocks it, right-click, Properties, tick Unblock, OK.
cd /d "%~dp0"
set P=watergate-records-in-the-groove-musical-excellence-on-the-river-spree
if exist "all-work\event-coverage\%P%" rmdir /s /q "all-work\event-coverage\%P%"
if exist "uploads\new\%P%" rmdir /s /q "uploads\new\%P%"
if exist "uploads\thumbs\new\%P%" rmdir /s /q "uploads\thumbs\new\%P%"
echo.
echo Done. Commit and push in GitHub Desktop.
echo.
pause

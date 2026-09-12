@echo off
REM Removes the Watergate Records piece from the repository.
REM Unzipping an update adds and overwrites files; it cannot delete one, so this
REM takes out the three folders that belonged to the page you asked to take down.
REM Double-click it once, here in the repository folder, then commit and push.
cd /d "%~dp0"
set P=watergate-records-in-the-groove-musical-excellence-on-the-river-spree
if exist "all-work\event-coverage\%P%" rmdir /s /q "all-work\event-coverage\%P%"
if exist "uploads\new\%P%" rmdir /s /q "uploads\new\%P%"
if exist "uploads\thumbs\new\%P%" rmdir /s /q "uploads\thumbs\new\%P%"
echo.
echo Watergate Records removed. Commit and push in GitHub Desktop.
echo.
pause

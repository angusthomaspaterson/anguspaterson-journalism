@echo off
setlocal
cd /d "%~dp0"
echo Looking for wayback-hunt.csv...
echo.
set FOUND=
for %%R in ("%USERPROFILE%" "%USERPROFILE%\Downloads" "%USERPROFILE%\Documents" "%SystemRoot%\System32" "%TEMP%" "C:\") do (
  if exist "%%~R\wayback-hunt.csv" (
    echo   found: %%~R\wayback-hunt.csv
    copy /y "%%~R\wayback-hunt.csv" "%~dp0wayback-hunt.csv" >nul && set FOUND=1
  )
)
if not defined FOUND (
  echo   not in the usual places, searching the whole user folder...
  for /f "delims=" %%F in ('dir /s /b "%USERPROFILE%\wayback-hunt.csv" 2^>nul') do (
    echo   found: %%F
    copy /y "%%F" "%~dp0wayback-hunt.csv" >nul && set FOUND=1
  )
)
echo.
if defined FOUND (
  echo Copied into this folder as wayback-hunt.csv. Tell Claude it is here.
) else (
  echo Could not find it. Re-run hunt-lost-images.bat with the fixed script instead.
)
echo.
pause

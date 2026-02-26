@echo off
:: ============================================================
:: Blood ^& Barter - Sync Custom Client Mods
:: ============================================================
:: Copies custom client+server mods from this server repo
:: to your local DayZ client install so you stay in sync.
::
:: Usage: double-click this file before launching DayZ.
:: ============================================================

:: Work from the directory this script lives in
pushd "%~dp0"

:: DayZ client is a sibling folder under steamapps\common\
:: Resolve the path so it doesn't contain ..
pushd "%~dp0..\DayZ" 2>nul
if errorlevel 1 (
    echo ERROR: DayZ client not found next to DayZServer folder.
    echo Expected: steamapps\common\DayZ
    pause
    exit /b 1
)
set "DAYZ_CLIENT=%CD%"
popd

echo ============================================
echo  Blood ^& Barter - Sync Custom Client Mods
echo ============================================
echo.
echo Server : %~dp0
echo Client : %DAYZ_CLIENT%
echo.

:: ============================================================
:: Custom client+server mods to sync.
:: Server-only mods (-serverMod=) do NOT need client copies.
:: Workshop mods are handled by Steam, skip those too.
:: ============================================================

call :sync_mod MinimapTweak

:: Clear client script cache so new PBOs are picked up
echo.
echo Clearing client script cache...
del /q "%LOCALAPPDATA%\DayZ\DataCache\cache.ch" >nul 2>&1
echo Done.

echo.
echo ============================================
echo  Sync complete! Launch DayZ and connect.
echo ============================================
popd
pause
exit /b 0

:: ============================================================
:sync_mod
:: Copies @%1 folder to the DayZ client directory
:: ============================================================
set "MOD_NAME=%~1"
if not exist "@%MOD_NAME%" (
    echo [SKIP] @%MOD_NAME% - not found in server folder
    exit /b 0
)
echo [SYNC] @%MOD_NAME%
xcopy /E /I /Y "@%MOD_NAME%" "%DAYZ_CLIENT%\@%MOD_NAME%" >nul
echo         -^> %DAYZ_CLIENT%\@%MOD_NAME%
exit /b 0

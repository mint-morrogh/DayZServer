@echo off
:: ============================================================
:: BAE-Z - Clear Character Cache
:: ============================================================
:: Clears your local DayZ character cache so you spawn fresh
:: on next connect. Does NOT touch the server world, loot,
:: vehicles, or bases — only your client-side character data.
::
:: Run this if your character is bugged (stuck bleeding,
:: can't use items, corrupted inventory, etc).
::
:: NOTE: The server admin must ALSO run RESET_PLAYERS.bat on
:: the server to delete players.db — otherwise the server
:: still has your old character saved. This script only
:: clears your LOCAL client cache.
:: ============================================================

setlocal
pushd "%~dp0"

echo ============================================
echo  BAE-Z - Clear Character Cache
echo ============================================
echo.
echo This will DELETE your local character data:
echo   - Character appearance and state
echo   - Client profile variables
echo   - Client script cache
echo.
echo You will spawn as a fresh character next time
echo you connect to the server.
echo.
echo Your keybinds and video settings are NOT affected.
echo Server world, loot, vehicles, and bases are NOT affected.
echo.
set /p CONFIRM="Type YES to confirm, or anything else to cancel: "
if /i not "%CONFIRM%"=="YES" (
    echo Cancelled. Nothing was deleted.
    pause
    exit /b 0
)

echo.
echo --- Clearing character data ---

:: Client-side character cache
set "CLEARED=0"
if exist "%USERPROFILE%\Documents\DayZ\chars.DayZProfile" (
    del /q "%USERPROFILE%\Documents\DayZ\chars.DayZProfile" 2>nul
    set "CLEARED=1"
)
if exist "%USERPROFILE%\Documents\DayZ\profile.vars.DayZProfile" (
    del /q "%USERPROFILE%\Documents\DayZ\profile.vars.DayZProfile" 2>nul
    set "CLEARED=1"
)
for %%f in ("%USERPROFILE%\Documents\DayZ\*_settings.DayZProfile") do (
    del /q "%%f" 2>nul
    set "CLEARED=1"
)
echo   [OK] Character profile data cleared

:: Client script cache
del /q "%LOCALAPPDATA%\DayZ\DataCache\cache.ch" 2>nul
echo   [OK] Client script cache cleared

echo.
echo ============================================
echo  Done! Your character has been reset.
echo  Launch DayZ and connect to spawn fresh.
echo ============================================
echo.
popd
pause
exit /b 0

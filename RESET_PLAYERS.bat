@echo off
:: ============================================================
:: BAE-Z - Reset Player Characters
:: ============================================================
:: Wipes all player character data on the server so everyone
:: spawns fresh. Does NOT touch the world state — loot,
:: vehicles, bases, and mod configs are all preserved.
::
:: IMPORTANT: Stop the server before running this!
::
:: This script also clears YOUR local client cache, so you
:: only need to run this one. Other players on different PCs
:: should run CLEAR_CHARACTER.bat on their machine.
:: ============================================================

setlocal
pushd "%~dp0"

echo ============================================
echo  BAE-Z - Reset Player Characters
echo ============================================
echo.
echo This will DELETE all player data:
echo   - Player characters and inventory (players.db)
echo   - Skill tree progress (ZenSkills)
echo   - Client character cache (local machine only)
echo.
echo The following are NOT affected:
echo   - World state (loot, dropped items)
echo   - Vehicles and bases
echo   - Dog/horse ownership
echo   - Server configs and mod settings
echo.
echo MAKE SURE THE SERVER IS STOPPED FIRST!
echo.
set /p CONFIRM="Type RESET to confirm, or anything else to cancel: "
if /i not "%CONFIRM%"=="RESET" (
    echo Cancelled. Nothing was deleted.
    pause
    exit /b 0
)

echo.
echo --- Resetting player data ---

:: Server-side player database
if exist "mpmissions\dayzOffline.chernarusplus\storage_1\players.db" (
    del /q "mpmissions\dayzOffline.chernarusplus\storage_1\players.db" 2>nul
    echo   [OK] players.db deleted
) else (
    echo   [--] players.db not found (already clean)
)

:: ZenSkills player progress
if exist "config\Zenarchist\Skills\PlayerDB" (
    del /q "config\Zenarchist\Skills\PlayerDB\*.json" 2>nul
    echo   [OK] Skill tree progress wiped
) else (
    echo   [--] No skill data found
)

:: Server script cache (force clean recompile)
del /q "config\DataCache\cache.ch" 2>nul
del /q "config\DataCache\cache_lock" 2>nul
echo   [OK] Server script cache cleared

echo.
echo --- Clearing local client character data ---

del /q "%USERPROFILE%\Documents\DayZ\chars.DayZProfile" 2>nul
del /q "%USERPROFILE%\Documents\DayZ\profile.vars.DayZProfile" 2>nul
del /q "%USERPROFILE%\Documents\DayZ\*_settings.DayZProfile" 2>nul
del /q "%LOCALAPPDATA%\DayZ\DataCache\cache.ch" 2>nul
echo   [OK] Client character cache cleared

echo.
echo ============================================
echo  Player reset complete!
echo  All players will spawn as fresh characters.
echo  Start the server with START_SERVER.bat
echo ============================================
echo.
echo NOTE: Your wife should also run CLEAR_CHARACTER.bat
echo       on her PC to clear her client cache.
echo.
popd
pause
exit /b 0

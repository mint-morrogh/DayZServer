@echo off
:: ============================================================
:: Blood ^& Barter - Pull Latest Updates
:: ============================================================
:: Run this before launch_dayz.bat if the launcher itself has
:: changed (e.g. new mod fixes, script updates). After this
:: completes, run launch_dayz.bat as normal.
:: ============================================================

pushd "%~dp0"

echo ============================================
echo  Blood ^& Barter - Update
echo ============================================
echo.

where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: git is not installed.
    echo Install git from https://git-scm.com then try again.
    pause
    exit /b 1
)

git pull --ff-only 2>&1
if errorlevel 1 (
    echo.
    echo [WARN] git pull failed - you may have local changes.
    echo        Try: git stash ^&^& git pull ^&^& git stash pop
) else (
    echo.
    echo [OK] Up to date. You can now run launch_dayz.bat.
)

echo.
popd
pause

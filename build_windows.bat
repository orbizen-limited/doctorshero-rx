@echo off
REM DoctorsHero Core - Windows Build Script
REM This script automates the build and installer creation process

echo ========================================
echo DoctorsHero Core - Windows Build Script
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo [1/4] Cleaning previous build...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [3/4] Building Windows release...
call flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter build failed
    pause
    exit /b 1
)

echo.
echo [4/4] Build completed successfully!
echo.
echo Built application location:
echo   build\windows\x64\runner\Release\DoctorsHero_Core.exe
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Test the application:
echo    - Run: build\windows\x64\runner\Release\DoctorsHero_Core.exe
echo.
echo 2. Create installer:
echo    - Install Inno Setup from: https://jrsoftware.org/isdl.php
echo    - Open: windows\installer.iss
echo    - Click: Build ^> Compile
echo    - Installer will be in: build\windows\installer\
echo.
echo 3. Distribute:
echo    - Upload installer to your server
echo    - Update version API endpoint
echo    - Share with users!
echo.
pause

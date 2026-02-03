@echo off
REM BestSub Desktop Build Script for Windows

echo ==========================================
echo BestSub Desktop Build Script
echo ==========================================
echo.

SET SCRIPT_DIR=%~dp0
SET PROJECT_ROOT=%SCRIPT_DIR%..
SET BINARY_NAME=bestsub.exe

echo Project root: %PROJECT_ROOT%
echo Desktop directory: %SCRIPT_DIR%
echo.

REM Check if Go is installed
where go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Go is not installed. Please install Go first.
    exit /b 1
)

echo [INFO] Go is installed
go version

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js first.
    exit /b 1
)

echo [INFO] Node.js is installed
node --version

REM Check if Rust is installed
where cargo >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Rust is not installed. Please install Rust first.
    exit /b 1
)

echo [INFO] Rust is installed
rustc --version
echo.

REM Step 1: Build the Go backend
echo [INFO] Step 1: Building Go backend...
cd /d %PROJECT_ROOT%

go build -o %BINARY_NAME% ./cmd/bestsub

if not exist %BINARY_NAME% (
    echo [ERROR] Failed to build Go backend
    exit /b 1
)

echo [INFO] Go backend built successfully: %BINARY_NAME%
echo.

REM Step 2: Copy binary to desktop directory
echo [INFO] Step 2: Copying binary to desktop directory...
copy /Y %BINARY_NAME% %SCRIPT_DIR%

if not exist %SCRIPT_DIR%%BINARY_NAME% (
    echo [ERROR] Failed to copy binary to desktop directory
    exit /b 1
)

echo [INFO] Binary copied successfully
echo.

REM Step 3: Install Node.js dependencies
echo [INFO] Step 3: Installing Node.js dependencies...
cd /d %SCRIPT_DIR%

if not exist node_modules (
    call npm install
) else (
    echo [INFO] Node modules already installed
)

echo.

REM Step 4: Build the Tauri application
echo [INFO] Step 4: Building Tauri application...
call npm run build

if %ERRORLEVEL% EQU 0 (
    echo [INFO] Build completed successfully!
    echo.
    echo [INFO] Installers can be found in:
    echo [INFO]   %SCRIPT_DIR%src-tauri\target\release\bundle\
    echo.
) else (
    echo [ERROR] Build failed
    exit /b 1
)

echo ==========================================
echo Build process completed!
echo ==========================================
pause

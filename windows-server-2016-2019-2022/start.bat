@echo off
setlocal

echo ====================================================
echo            Starting Fluent Bit (Windows)...
echo ====================================================

rem Fluent Bit installation root. Update this path if installed elsewhere.
set "FB_INSTALL_HOME=C:\Users\ironp\Desktop\fluent-bit"
echo [INFO] Using FB_INSTALL_HOME: %FB_INSTALL_HOME%
set "FB_BIN=%FB_INSTALL_HOME%\bin\fluent-bit.exe"

rem Use the directory containing this script and all configuration files.
set "CONFIG_DIR=%~dp0"
set "CONFIG_FILE=%CONFIG_DIR%fluent-bit.conf"
echo [INFO] Using CONFIG_FILE: %CONFIG_FILE%

if not exist "%FB_BIN%" (
    echo [ERROR] Fluent Bit executable not found: %FB_BIN%
    pause
    exit /b 1
)

if not exist "%CONFIG_FILE%" (
    echo [ERROR] Configuration file not found: %CONFIG_FILE%
    pause
    exit /b 1
)

if /i "%~1"=="--check" goto check_config

echo [INFO] Stopping old Fluent Bit process...
taskkill /f /im fluent-bit.exe >nul 2>&1

echo [SUCCESS] Preparation complete. Starting Fluent Bit...
echo ----------------------------------------------------

pushd "%CONFIG_DIR%" || exit /b 1
"%FB_BIN%" -c "%CONFIG_FILE%"
set "FB_EXIT_CODE=%ERRORLEVEL%"
popd
goto finish

:check_config
pushd "%CONFIG_DIR%" || exit /b 1
"%FB_BIN%" --dry-run -c "%CONFIG_FILE%"
set "FB_EXIT_CODE=%ERRORLEVEL%"
popd

:finish
if /i not "%~1"=="--check" pause
exit /b %FB_EXIT_CODE%

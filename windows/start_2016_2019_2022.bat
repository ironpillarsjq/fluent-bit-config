@echo off
setlocal

rem Decode Fluent Bit UTF-8 output consistently in the Windows console.
chcp 65001 >nul

echo ====================================================
echo            Starting Fluent Bit (Windows)...
echo ====================================================

rem Fluent Bit installation root. Select the path by profile.
if /i "%~1"=="2008" goto set_2008_home
if /i "%~1"=="legacy" goto set_2008_home
set "FB_INSTALL_HOME=%~dp0..\.."
goto home_selected

:set_2008_home
set "FB_INSTALL_HOME=%~dp0..\..\..\fluent-bit-1.8.15-win64"

:home_selected
echo [INFO] Using FB_INSTALL_HOME: %FB_INSTALL_HOME%
set "FB_BIN=%FB_INSTALL_HOME%\bin\fluent-bit.exe"

rem Create a timestamped local log file for this run.
set "LOCAL_LOG_PATH=%~dp0local-logs"
if /i "%~1"=="2008" set "LOCAL_LOG_PREFIX=windows_2008"
if /i "%~1"=="legacy" set "LOCAL_LOG_PREFIX=windows_2008"
if not defined LOCAL_LOG_PREFIX set "LOCAL_LOG_PREFIX=windows"
set "FLB_TIMESTAMP="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')" 2^>nul`) do if not defined FLB_TIMESTAMP set "FLB_TIMESTAMP=%%I"
if not defined FLB_TIMESTAMP set "FLB_TIMESTAMP=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "FLB_TIMESTAMP=%FLB_TIMESTAMP: =0%"
set "LOCAL_LOG_FILE=%LOCAL_LOG_PREFIX%_%FLB_TIMESTAMP%.jsonl"
if not exist "%LOCAL_LOG_PATH%" mkdir "%LOCAL_LOG_PATH%"
echo [INFO] Local log file: %LOCAL_LOG_PATH%\%LOCAL_LOG_FILE%

rem Use the directory containing this script and all configuration files.
rem start_2008.bat calls this shared launcher with the 2008 profile.
set "CONFIG_DIR=%~dp0"
set "CONFIG_FILE=%CONFIG_DIR%fluent-bit.conf"
if /i "%~1"=="2008" set "CONFIG_FILE=%CONFIG_DIR%fluent-bit-2008.conf"
if /i "%~1"=="legacy" set "CONFIG_FILE=%CONFIG_DIR%fluent-bit-2008.conf"
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
if /i "%~1"=="2008" if /i "%~2"=="--check" goto check_config
if /i "%~1"=="legacy" if /i "%~2"=="--check" goto check_config

echo [INFO] Stopping old Fluent Bit process...
taskkill /f /im fluent-bit.exe >nul 2>&1

echo [SUCCESS] Preparation complete. Starting Fluent Bit...
echo ----------------------------------------------------

pushd "%CONFIG_DIR%" || exit /b 1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$utf8 = New-Object System.Text.UTF8Encoding($false); [Console]::OutputEncoding = $utf8; $OutputEncoding = $utf8; & $env:FB_BIN -c $env:CONFIG_FILE; exit $LASTEXITCODE"
set "FB_EXIT_CODE=%ERRORLEVEL%"
popd
goto finish

:check_config
pushd "%CONFIG_DIR%" || exit /b 1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$utf8 = New-Object System.Text.UTF8Encoding($false); [Console]::OutputEncoding = $utf8; $OutputEncoding = $utf8; & $env:FB_BIN --dry-run -c $env:CONFIG_FILE; exit $LASTEXITCODE"
set "FB_EXIT_CODE=%ERRORLEVEL%"
popd

:finish
if /i not "%~1"=="--check" if /i not "%~2"=="--check" pause
exit /b %FB_EXIT_CODE%

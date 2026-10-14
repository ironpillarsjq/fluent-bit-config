@echo off
setlocal

echo ====================================================
echo        Clear Fluent Bit local pending logs
 echo ====================================================

set "CONF_DIR=%~dp0"
set "BUFFER_DIR=%CONF_DIR%..\..\buffer"
set "DB_ROOT=%CONF_DIR%..\..\"

echo [INFO] Stopping Fluent Bit...
taskkill /f /im fluent-bit.exe >nul 2>&1

echo [INFO] Preserving local JSONL files under %CONF_DIR%local-logs
echo [INFO] Resetting the log forwarding start point to the current event positions...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%CONF_DIR%reset_winlog_checkpoints.ps1" -DbRoot "%DB_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to reset winlog checkpoints. No profile was started.
    exit /b 1
)

echo [INFO] Clearing filesystem buffer: %BUFFER_DIR%
if exist "%BUFFER_DIR%" rmdir /s /q "%BUFFER_DIR%"
mkdir "%BUFFER_DIR%" >nul 2>&1

echo [SUCCESS] Cache cleared and log forwarding start point reset to the cleanup time.
@echo [INFO] Starting modern Windows profile...
call "%CONF_DIR%start_2016_2019_2022.bat"
exit /b %ERRORLEVEL%



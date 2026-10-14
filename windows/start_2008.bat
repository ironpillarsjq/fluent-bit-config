@echo off
rem Reuse the shared launcher and select the Fluent Bit 1.8 / Server 2008 configuration.
call "%~dp0start_2016_2019_2022.bat" 2008 %*
exit /b %ERRORLEVEL%

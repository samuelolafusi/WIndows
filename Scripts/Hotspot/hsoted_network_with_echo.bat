@echo off
:: CMD script to start Mobile Hotspot on Windows 11

:: Set the SSID and password
set SSID=olafusi
set PASSWORD=9804/X9f

:: Check if the hosted network is supported
netsh wlan show drivers | findstr /C:"Hosted network supported  : Yes" >nul
if errorlevel 1 (
    echo Hosted network is not supported on this device.
    pause
    exit /b 1
)

:: Enable and configure the mobile hotspot
netsh wlan set hostednetwork mode=allow ssid=%SSID% key=%PASSWORD%

:: Start the mobile hotspot
netsh wlan start hostednetwork

:: Check for errors
if errorlevel 1 (
    echo Failed to start the hosted network.
    pause
    exit /b 1
)

:: Show the status of the mobile hotspot
netsh wlan show hostednetwork

echo Mobile Hotspot started successfully.
pause

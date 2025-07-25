# PowerShell script to start Mobile Hotspot on Windows 11

# Function to start the hotspot
function Start-Hotspot {
    # Enable and configure the mobile hotspot
    netsh wlan set hostednetwork mode=allow ssid=olafusi key=9804/X9f
    netsh wlan start hostednetwork
}

# Run the function to start the hotspot
Start-Hotspot

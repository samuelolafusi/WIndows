# Set SSID (Wi-Fi name) and Password
$SSID = "MyHotspot"
$Password = "MySecurePassword123"

# Configure the hosted network
netsh wlan set hostednetwork mode=allow ssid=$SSID key=$Password

# Start the hosted network
netsh wlan start hostednetwork

# Check the status
$status = netsh wlan show hostednetwork | Select-String "Status"
if ($status -match "Started") {
    Write-Output "Hosted network started successfully. SSID: $SSID"
} else {
    Write-Output "Failed to start hosted network. Please check if your adapter supports hosted networks and try again."
}
# This script logs a user in and gives user, group, organization and directory level read and write access

# Check if running as Administrator
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isElevated) {
    Write-Warning "This script requires administrative privileges. Relaunching as Administrator..."
    Start-Process -FilePath "pwsh.exe" -ArgumentList "-NoProfile -ExecutionPolicy bypass -File `"$PSCommandPath`"" -Verb RunAs
}

connect-mggraph -scopes "user.readwrite.all","group.readwrite.all","organization.readwrite.all","directory.readwrite.all"
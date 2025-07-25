# This script will assign admin roles.
# It asks the user to provide the UPN and Admin role

echo "Note that you need rolemanagement.readwrite.directory scope to assign roles"
echo " "
echo "You will be redirected to your browser to log in"
echo " "

connect-mggraph -scopes "user.readwrite.all","group.readwrite.all","directory.readwrite.all","organization.readwrite.all","rolemanagement.readwrite.directory"

# Prompt for user input
$userUPN = Read-Host -Prompt "Enter User Sign-in Name or UPN"
if ([string]::IsNullOrWhiteSpace($userUPN)) {
    Write-Error "UPN cannot be empty."
    Read-Host "Press Enter to exit..."
    disconnect-mggraph
    exit
}

echo " "

Write-Output "Checking if $userUPN exists"

echo " "

# Retrieve user ID
try {
    $user = Get-MgUser -Filter "userPrincipalName eq '$userUPN'" -ErrorAction Stop
    if (-not $user) {
        Write-Error "User with UPN '$userUPN' not found."
        Read-Host "Press Enter to exit..."
        exit
    }
    $userId = $user.Id
    Write-Output "Found user: $userUPN (ID: $userId)"
} catch {
    Write-Error "Failed to retrieve user '$userUPN': $_"
    Read-Host "Press Enter to exit..."
    disconnect-mggraph
    exit
}

echo " "

$roleName = Read-Host -Prompt "Enter Admin role to be assigned"
if ([string]::IsNullOrWhiteSpace($roleName)) {
    Write-Error "Role name cannot be empty."
    Read-Host "Press Enter to exit..."
    disconnect-mggraph
    exit
}

echo " "

# validation of Admin role from M365 could be added here

$title = "Confirm Action"
write-output "You have entered $userUPN and $roleName as the User sign-in name and Admin role, respectively."
Start-Sleep -Seconds 5
$message = "Do you want to proceed with assignment?"
$yes = [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Proceed with the operation")
$no = [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Cancel the operation")
$options = @($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
if ($result -ne 0) {
    Write-Output "Cancelled."
    Read-Host "Press Enter to exit..."
    disconnect-mggraph
    exit
}

echo " "
Write-Output "Script is cooking, result will be shown soon."

$role = Get-MgDirectoryRole | Where-Object {$_.displayName -eq $roleName}
if ($role -eq $null) {
    $roleTemplate = (Get-MgDirectoryRoleTemplate | Where-Object {$_.displayName -eq $roleName}).id
    New-MgDirectoryRole -DisplayName $roleName -RoleTemplateId $roleTemplate
    $role = Get-MgDirectoryRole | Where-Object {$_.displayName -eq $roleName}
}

# Check if user is already a member
try {
    $existingMember = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Where-Object { $_.Id -eq $userId }
    if ($existingMember) {
        Write-Warning "User '$userUPN' is already a member of role '$roleName'."
        Read-Host "Press Enter to exit..."
        disconnect-mggraph
        exit
    }
} catch {
    Write-Warning "Failed to check existing role membership: $_"
}

$newRoleMember =@{
    "@odata.id"= "https://graph.microsoft.com/v1.0/users/$userId"
    }
New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.Id -BodyParameter $newRoleMember

# Write-Output "Successfully assigned role '$roleName' to user '$userUPN'."

echo " "

# Confirm role assignment
try {
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -ErrorAction Stop
    $roles_membersID = $members.Id
    Write-Output "Current User IDs with role '$roleName':"
    $roles_membersID | ForEach-Object { Write-Output "  - $_" }
    echo " "
    # Check if $userId is in $roles_membersID
    if ($roles_membersID -contains $userId) {
        Write-Output "Success: User with UPN '$userUPN' has been added to the role '$roleName'."
    } else {
        Write-Error "Failure: User with UPN '$userUPN' was not added to the role '$roleName'."
    }
} catch {
    Write-Error "Failed to retrieve role members for '$roleName': $_"
}


$title1 = "M365 Logout"
$message = "Do you want to log out of M356?"
$yes = [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Proceed with the operation")
$no = [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Cancel the operation")
$options = @($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
if ($result -eq 0) {
    disconnect-mggraph
    echo "You are logged out"
    Read-Host "Press Enter to exit the script..."
    exit
}

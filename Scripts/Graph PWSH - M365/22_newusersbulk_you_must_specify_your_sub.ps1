# login and retrieve M365 plan
connect-mggraph -scopes "User.readwrite.all","group.readwrite.all","organization.read.all","directory.readwrite.all" -NoWelcome

# Import the CSV file
$users = Import-Csv -Path "C:\Users\owner\Desktop\Mine\IT_HW\IT\WIndows\LAB\Documentation\22_newusers.csv"

# Create a password profile
$PasswordProfile = @{
    Password = 'P@ssw0rd!2025'
    ForceChangePasswordNextSignIn = $true
    }

# Loop through each user in the CSV file
foreach ($user in $users) {
    # Create a new user
    $newUser = New-MgUser -DisplayName $user.DisplayName -GivenName $user.FirstName -Surname $user.LastName -UserPrincipalName $user.UserPrincipalName -UsageLocation $user.UsageLocation -MailNickname $user.MailNickname -PasswordProfile $passwordProfile -AccountEnabled

# Assign a license to the new user
    $e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'Office_365_E5_(no_Teams)'
    Set-MgUserLicense -UserId $newUser.Id -AddLicenses @{SkuId = $e5Sku.SkuId} -RemoveLicenses @()
}

# Export all users to a CSV file
Get-MgUser | select displayname, id, mail, userprincipalname | Export-Csv -Path "C:\Users\owner\Desktop\Mine\IT_HW\IT\WIndows\LAB\Documentation\22_allusers.csv" -NoTypeInformation
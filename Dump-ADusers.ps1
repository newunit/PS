# Connect to Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All"

# Define CSV file export location variable
$Csvfile = "AllAzureADUsers.csv"

# Retrieve users using the Microsoft Graph API with property
$propertyParams = @{
    All            = $true
    ExpandProperty = 'manager'
}

$users = Get-MgUser @propertyParams
$totalUsers = $users.Count

# Initialize progress counter
$progress = 0

# Create an array to store user objects
$userObjects = @()

# Collect and loop through all users
foreach ($index in 0..($totalUsers - 1)) {
    $user = $users[$index]

    # Update progress counter
    $progress++
    
    # Calculate percentage complete
    $percentComplete = ($progress / $totalUsers) * 100

    # Define progress bar parameters
    $progressParams = @{
        Activity        = "Processing Users"
        Status          = "User $($index + 1) of $totalUsers - $($user.userPrincipalName) - $($percentComplete -as [int])% Complete"
        PercentComplete = $percentComplete
    }
    
    # Display progress bar
    Write-Progress @progressParams

    # Get manager information
    $managerDN = $user.Manager.AdditionalProperties.displayName
    $managerUPN = $user.Manager.AdditionalProperties.userPrincipalName

    # Create an object to store user properties
    $userObject = [PSCustomObject]@{
        "ID"                          = $user.id
        "First name"                  = $user.givenName
        "Last name"                   = $user.surname
        "Display name"                = $user.displayName
        "User principal name"         = $user.userPrincipalName
        "Email address"               = $user.mail
        "Job title"                   = $user.jobTitle
        "Manager display name"        = $managerDN
        "Manager user principal name" = $managerUPN
        "Department"                  = $user.department
        "Company"                     = $user.companyName
        "Office"                      = $user.officeLocation
        "Employee ID"                 = $user.employeeID
        "Mobile"                      = $user.mobilePhone
        "Phone"                       = $user.businessPhones -join ','
        "Street"                      = $user.streetAddress
        "City"                        = $user.city
        "Postal code"                 = $user.postalCode
        "State"                       = $user.state
        "Country"                     = $user.country
        "User type"                   = $user.userType
        "On-Premises sync"            = if ($user.onPremisesSyncEnabled) { "enabled" } else { "disabled" }
        "Account status"              = if ($user.accountEnabled) { "enabled" } else { "disabled" }
        "Account Created on"          = $user.createdDateTime
        "Licensed"                    = if ($user.assignedLicenses.Count -gt 0) { "Yes" } else { "No" }
    }

    # Add the user object to the array
    $userObjects += $userObject
}

# Export users to CSV
$userObjects | Sort-Object "Display name" | Export-Csv -Path $Csvfile -NoTypeInformation -Encoding UTF8

# Display data in Out-GridView
# f$userObjects | Out-GridView

# Show export location
Write-Host "CSV file exported to: $Csvfile" -ForegroundColor Green
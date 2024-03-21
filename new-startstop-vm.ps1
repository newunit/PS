# Install required PowerShell modules if not already installed
$requiredModules = @("Az.Accounts", "Az.Compute")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

# Import required PowerShell modules
Import-Module Az.Accounts
Import-Module Az.Compute

# Prompt for username and password
$username = Read-Host -Prompt "Enter your Azure username"
$password = Read-Host -Prompt "Enter your Azure password" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Log in to Azure
Connect-AzAccount -Credential $credential

# Enumerate Azure subscriptions
$subscriptions = Get-AzSubscription | Select-Object -Property Name, Id

# Display enumerated subscriptions with numbers
Write-Host "Enumerated Subscriptions:"
for ($i = 0; $i -lt $subscriptions.Count; $i++) {
    Write-Host "$($i+1): $($subscriptions[$i].Name)"
}

# Prompt to select a subscription by number
$selectedSubscriptionIndex = Read-Host -Prompt "Enter the number of the subscription"
if ($selectedSubscriptionIndex -lt 1 -or $selectedSubscriptionIndex -gt $subscriptions.Count) {
    Write-Host "Invalid subscription number. Please select a valid number."
    exit
}
$selectedSubscriptionObject = $subscriptions[$selectedSubscriptionIndex - 1]

# Set the selected subscription context
Set-AzContext -SubscriptionId $selectedSubscriptionObject.Id

# Enumerate resource groups in the selected subscription
$resourceGroups = Get-AzResourceGroup

# Display enumerated resource groups with numbers
Write-Host "Enumerated Resource Groups in the selected subscription:"
for ($i = 0; $i -lt $resourceGroups.Count; $i++) {
    Write-Host "$($i+1): $($resourceGroups[$i].ResourceGroupName)"
}

# Prompt to select a resource group by number
$selectedResourceGroupIndex = Read-Host -Prompt "Enter the number of the resource group"
if ($selectedResourceGroupIndex -lt 1 -or $selectedResourceGroupIndex -gt $resourceGroups.Count) {
    Write-Host "Invalid resource group number. Please select a valid number."
    exit
}
$selectedResourceGroup = $resourceGroups[$selectedResourceGroupIndex - 1]

# Check if the selected resource group is not null
if (-not $selectedResourceGroup) {
    Write-Host "Selected resource group is null or empty. Exiting."
    exit
}

# Enumerate VMs in the selected resource group
$vms = Get-AzVM -ResourceGroupName $selectedResourceGroup.ResourceGroupName -Status

# Check if VMs were retrieved successfully
if (-not $vms) {
    Write-Host "Failed to retrieve VMs in the selected resource group."
    exit
}

# Display enumerated VMs with numbers
Write-Host "Enumerated VMs in the selected resource group '$($selectedResourceGroup.ResourceGroupName)':"
for ($i = 0; $i -lt $vms.Count; $i++) {
    Write-Host "$($i+1): $($vms[$i].Name)"
}

# Prompt to select a VM by number
$selectedVMIndex = Read-Host -Prompt "Enter the number of the VM to start/stop"
if ($selectedVMIndex -lt 1 -or $selectedVMIndex -gt $vms.Count) {
    Write-Host "Invalid VM number. Please select a valid number."
    exit
}
$selectedVM = $vms[$selectedVMIndex - 1]

# Get the current state of the selected VM
if ($selectedVM.PowerState -eq "VM running") {
    $action = Read-Host -Prompt "The VM is currently running. Enter 'stop' to stop it, or 'cancel' to exit"
    if ($action -eq "stop") {
        Stop-AzVM -ResourceGroupName $selectedResourceGroup.ResourceGroupName -Name $selectedVM.Name -Force
        Write-Host "Stopping VM '$($selectedVM.Name)'..."
    } elseif ($action -eq "cancel") {
        Write-Host "Exiting without performing any action."
        exit
    } else {
        Write-Host "Invalid action. Exiting without performing any action."
        exit
    }
} elseif ($selectedVM.PowerState -eq "VM deallocated") {
    $action = Read-Host -Prompt "The VM is currently stopped. Enter 'start' to start it, or 'cancel' to exit"
    if ($action -eq "start") {
        Start-AzVM -ResourceGroupName $selectedResourceGroup.ResourceGroupName -Name $selectedVM.Name
        Write-Host "Starting VM '$($selectedVM.Name)'..."
    } elseif ($action -eq "cancel") {
        Write-Host "Exiting without performing any action."
        exit
    } else {
        Write-Host "Invalid action. Exiting without performing any action."
        exit
    }
} else {
    Write-Host "Failed to determine the current state of the VM."
    exit
}

# Prompt to disconnect from Azure account
$disconnectChoice = Read-Host -Prompt "Do you want to disconnect from Azure? (yes/no)"
if ($disconnectChoice -eq "yes") {
    Disconnect-AzAccount
    Write-Host "Disconnected from Azure account."
} elseif ($disconnectChoice -eq "no") {
    Write-Host "Not disconnecting from Azure account."
} else {
    Write-Host "Invalid choice. Not disconnecting from Azure account."
}

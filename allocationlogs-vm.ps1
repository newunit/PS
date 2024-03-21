# Function to install or update the Az module
function InstallOrUpdateAzModule {
    $moduleName = "Az"
    $module = Get-Module -ListAvailable -Name $moduleName
    if ($module -ne $null -and $module.Version -lt [Version]"5.0.0") {
        Write-Host "Updating $moduleName module..."
        Update-Module -Name $moduleName
    }
    elseif ($module -eq $null) {
        Write-Host "Installing $moduleName module..."
        Install-Module -Name $moduleName -AllowClobber -Scope CurrentUser -Force
    }
    Import-Module $moduleName -Force
    Write-Host "$moduleName module is ready."
}

# Install or update the Az module
InstallOrUpdateAzModule

# Prompt for Azure admin credentials
$credential = Get-Credential -Message "Enter your Azure admin user ID and password"

# Connect to Azure with provided credentials
Connect-AzAccount -Credential $credential

# Enumerate all VMs in the account
$vms = Get-AzVM
for ($i = 0; $i -lt $vms.Count; $i++) {
    Write-Host "$($i+1). $($vms[$i].Name)"
}

# Prompt user to select a VM by number
$selectedVMNumber = Read-Host "Select the VM by number"
$selectedVM = $vms[$selectedVMNumber - 1]

# Confirm VM selection
Write-Host "You selected VM: $($selectedVM.Name)"

# Define the time range for the activity log query (last 90 days)
$endTime = Get-Date
$startTime = $endTime.AddDays(-90)

# Query the Activity Log for deallocation and reallocation events
$activityLogs = Get-AzLog -ResourceId $selectedVM.Id -StartTime $startTime -EndTime $endTime | Where-Object {
    $_.OperationName.Value -match "deallocate|start" -and $_.Status.Value -eq "Succeeded"
}

# Prepare data for export
$exportData = $activityLogs | Select-Object @{Name="Time"; Expression={$_.EventTimestamp}}, @{Name="Event"; Expression={$_.OperationName.Value}}

# Export to CSV
$csvFileName = "VM_${selectedVM.Name}_ActivityLogs.csv"
$exportData | Export-Csv -Path $csvFileName -NoTypeInformation

Write-Host "Activity logs exported to $csvFileName"

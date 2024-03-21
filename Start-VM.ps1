# Start VM
$resourceGroupName = "AutoTest"
$vmName = "junk"

Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
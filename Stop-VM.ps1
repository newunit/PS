# Start VM
$resourceGroupName = "AutoTest"
$vmName = "junk"

Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
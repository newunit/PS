# Prompt for admin credentials
$adminCredentials = Get-Credential -Message "Please enter your admin account credentials."

# Connect to Exchange Online using the admin credentials
Connect-ExchangeOnline -Credential $adminCredentials

# Prompt for the Distribution Group name
$groupName = Read-Host -Prompt "Enter the Distribution Group name from which you want to remove a member"

# Prompt for the member to be removed
$member = Read-Host -Prompt "Enter the email address of the member you want to remove"

# Remove the specified member from the specified Distribution Group
Remove-DistributionGroupMember -Identity $groupName -Member $member -Confirm:$false

# Output message to confirm action
Write-Host "Member $member has been removed from Distribution Group $groupName."

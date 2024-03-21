Connect-IPPSSession -UserPrincipalName Kevin@jlwarranty.com

New-ComplianceSearch -Name "eaglesfan2600@gmail.com" -ExchangeLocation all -ContentMatchQuery 'sent>=01/01/2010 AND sent<=03/14/2024 AND from:"eaglesfan2600@gmail.com" '

Start-ComplianceSearch -Identity "eaglesfan2600@gmail.com"

Get-ComplianceSearch -Identity "eaglesfan2600@gmail.com" | Format-List

New-ComplianceSearchAction -SearchName "eaglesfan2600@gmail.com" -Purge -PurgeType HardDelete

Disconnect-ExchangeOnline
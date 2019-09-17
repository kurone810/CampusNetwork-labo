Get-VM | Where-Object {$_.Name -like "*vyos*" -and $_.Name -ne "vyOS_template"}| Start-VM
Get-VM
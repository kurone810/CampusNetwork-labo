Get-VM | Where-Object {$_.Name -like "*vyos*" -and $_.Name -ne "vyOS_template"} | Stop-VM -Force
Get-VM

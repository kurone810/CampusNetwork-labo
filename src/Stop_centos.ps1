Get-VM | Where-Object {$_.Name -like "*CentOS*-labo" -and $_.Name -ne "CentOS7-1804"} | Stop-VM -Force
Get-VM
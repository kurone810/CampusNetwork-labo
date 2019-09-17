Get-VM | Where-Object {$_.Name -like "*vyos*" -and $_.Name -ne "vyOS_template"} | Stop-VM
Get-VM | Where-Object {$_.Name -like "*vyos*" -and $_.Name -ne "vyOS_template"} 

Remove-VMDvdDrive "vyOS_LAN1" -ControllerNumber 1 -ControllerLocation 0
Remove-VMDvdDrive "vyOS_LAN2" -ControllerNumber 1 -ControllerLocation 0
Remove-VMDvdDrive "vyOS_DC3" -ControllerNumber 1 -ControllerLocation 0
Remove-VMDvdDrive "vyOS_DC4"-ControllerNumber 1 -ControllerLocation 0

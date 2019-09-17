Get-VMSwitch | Where-Object {$_.Name -ne "既定のスイッチ" -and $_.Name -ne "Default Switch" } | Remove-VMSwitch -Force
Get-VMSwitch
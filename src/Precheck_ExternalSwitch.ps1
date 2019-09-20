$Status = Get-VMSwitch | Where-Object {$_.SwitchType -eq "External"}
if($Status.Name -ne $null){
    Write-Host "警告：既に外部スイッチ:"$Status.Name"が存在しており、正常にlaboをBuildすることができません。" -ForegroundColor Red
    Write-Host "　　　既存のスイッチを削除するか、一時的に別種別のスイッチに切り替えてから実施してください。"  -ForegroundColor Red
}else{
    Write-Host "ExternalSwitch:ok" -ForegroundColor Blue
}


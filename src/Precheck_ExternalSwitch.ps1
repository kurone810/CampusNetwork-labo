$Status = Get-VMSwitch | Where-Object {$_.SwitchType -eq "External"}
if($Status.Name -ne $null){
    echo "警告：既に外部スイッチ:"$Status.Name"が存在しており、正常にlaboをBuildすることができません。"
    echo "既存のスイッチを削除するか、一時的に別種別のスイッチに切り替えてから実施してください。"
}


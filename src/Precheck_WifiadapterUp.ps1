$WiFi = Get-NetAdapter | Where-Object {$_.Name -eq "Wi-Fi"}
if($WiFi.Status -ne "up"){
    write-host "Wi-Fiの接続を有効化してください"
}else{
    Write-Host "WifiNetwork:ok" -ForegroundColor Blue
}
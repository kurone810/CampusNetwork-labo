#Requires -RunAsAdministrator

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$wifiAdapterName = $config.switches.external.netAdapterName
$WiFi = Get-NetAdapter | Where-Object { $_.Name -eq $wifiAdapterName }

if ($WiFi.Status -ne "up") {
    Write-Host "Wi-Fiの接続を有効化してください"
} else {
    Write-Host "WifiNetwork:ok" -ForegroundColor Blue
}

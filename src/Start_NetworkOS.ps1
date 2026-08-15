#Requires -RunAsAdministrator

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

Get-VM | Where-Object { $_.Name -like $config.filters.networkOS -and $_.Name -ne $config.excludedVMs.networkOS } | Start-VM
Get-VM

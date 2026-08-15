#Requires -RunAsAdministrator

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

Get-VM | Where-Object { $_.Name -like $config.filters.server -and $_.Name -ne $config.excludedVMs.server } | Start-VM
Get-VM

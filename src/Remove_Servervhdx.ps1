#Requires -RunAsAdministrator

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

Get-ChildItem -Path $config.paths.vhdPath | Where-Object { $_.Name -like $config.filters.serverVhdx -and $_.Name -notlike "*$($config.excludedVMs.server)*" } | Remove-Item -Force
Get-ChildItem -Path $config.paths.vhdPath

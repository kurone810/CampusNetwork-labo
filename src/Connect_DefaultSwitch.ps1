#Requires -RunAsAdministrator

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$serverVMs = $config.vmNaming.server.dmz + $config.vmNaming.server.siteA + $config.vmNaming.server.siteB
$networkOSVMs = $config.vmNaming.networkOS.external + $config.vmNaming.networkOS.siteA + $config.vmNaming.networkOS.siteB

$DefaultSwitchname = $config.switches.default.name
$DefaultNetworkAdapter = $config.networkAdapters.default

# Connect Server VMs to Default Switch
foreach ($vm in $serverVMs) {
    Connect-VMNetworkAdapter -VMName $vm -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname
}

# Connect NetworkOS VMs to Default Switch
foreach ($vm in $networkOSVMs) {
    Connect-VMNetworkAdapter -VMName $vm -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname
}

#Get-VM | Where-Object { $_.Name -like $config.filters.server } | Start-VM
#Get-VM

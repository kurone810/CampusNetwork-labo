#Requires -RunAsAdministrator

# Load Hyper-V configuration from external JSON file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$serverVMs = $config.vmNaming.server.dmz + $config.vmNaming.server.siteA + $config.vmNaming.server.siteB
$networkOSVMs = $config.vmNaming.networkOS.external + $config.vmNaming.networkOS.siteA + $config.vmNaming.networkOS.siteB

$MGMTNetworkAdapter = $config.networkAdapters.management

# Disconnect management NIC from Default Switch for Server VMs
foreach ($vm in $serverVMs) {
    $adapter = Get-VMNetworkAdapter -VMName $vm -Name $MGMTNetworkAdapter -ErrorAction SilentlyContinue
    if ($adapter) {
        Disconnect-VMNetworkAdapter -VMName $vm -Name $MGMTNetworkAdapter
        Write-Output "Disconnected $MGMTNetworkAdapter from Default Switch on $vm"
    }
    else {
        Write-Output "Management adapter not found on $vm"
    }
}

# Disconnect management NIC from Default Switch for NetworkOS VMs
foreach ($vm in $networkOSVMs) {
    $adapter = Get-VMNetworkAdapter -VMName $vm -Name $MGMTNetworkAdapter -ErrorAction SilentlyContinue
    if ($adapter) {
        Disconnect-VMNetworkAdapter -VMName $vm -Name $MGMTNetworkAdapter
        Write-Output "Disconnected $MGMTNetworkAdapter from Default Switch on $vm"
    }
    else {
        Write-Output "Management adapter not found on $vm"
    }
}

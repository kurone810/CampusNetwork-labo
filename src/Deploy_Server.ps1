#Requires -RunAsAdministrator

# Load Hyper-V configuration from external JSON file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$vhdpath = $config.paths.vhdPath
$imagepath = $config.paths.serverIsoPath

$dmzVMs = $config.vmNaming.server.dmz
$siteAVMs = $config.vmNaming.server.siteA
$siteBVMs = $config.vmNaming.server.siteB

$vhdSizeBytes = [System.UInt64]($config.resources.server.vhdSizeGB * 1GB)
$memorySizeBytes = [System.UInt64]($config.resources.server.memoryMB * 1MB)
$dynamicMemory = $config.resources.server.dynamicMemory
$generation = $config.resources.server.generation
$bootDevice = $config.resources.server.bootDevice

$DMZSwitchname01 = $config.switches.dmz.name
$siteA_INTSwitchname01 = $config.switches.siteAInternal.name
$siteB_INTSwitchname01 = $config.switches.siteBInternal.name

$DMZNetworkAdapter01 = $config.networkAdapters.dmz
$INTNetworkAdapter01 = $config.networkAdapters.internal

function New-ServerVM {
    param(
        [string]$Name,
        [string]$AdapterName,
        [string]$SwitchName
    )

    New-VHD -Path "$vhdpath$Name.vhdx" -SizeBytes $vhdSizeBytes
    New-VM -Name $Name -MemoryStartupBytes $memorySizeBytes -VHDPath "$vhdpath$Name.vhdx" -Generation $generation -BootDevice $bootDevice
    Set-VMDvdDrive $Name -Path $imagepath

    if (-not $dynamicMemory) {
        Set-VMMemory -VMName $Name -DynamicMemoryEnabled $false -StartupBytes $memorySizeBytes
    }

    Add-VMNetworkAdapter -VMName $Name -Name $AdapterName
    Connect-VMNetworkAdapter -VMName $Name -Name $AdapterName -SwitchName $SwitchName
}

foreach ($vm in $dmzVMs) {
    New-ServerVM -Name $vm -AdapterName $DMZNetworkAdapter01 -SwitchName $DMZSwitchname01
}

foreach ($vm in $siteAVMs) {
    New-ServerVM -Name $vm -AdapterName $INTNetworkAdapter01 -SwitchName $siteA_INTSwitchname01
}

foreach ($vm in $siteBVMs) {
    New-ServerVM -Name $vm -AdapterName $INTNetworkAdapter01 -SwitchName $siteB_INTSwitchname01
}

#Get-VM | Where-Object { $_.Name -like $config.filters.server } | Start-VM
#Get-VM

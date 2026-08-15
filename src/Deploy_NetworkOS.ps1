#Requires -RunAsAdministrator

# Load Hyper-V configuration from external JSON file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$vhdpath = $config.paths.vhdPath
$imagepath = $config.paths.networkOSIsoPath

$externalVMs = $config.vmNaming.networkOS.external
$siteAVMs = $config.vmNaming.networkOS.siteA
$siteBVMs = $config.vmNaming.networkOS.siteB

$vhdSizeBytes = [System.UInt64]($config.resources.networkOS.vhdSizeGB * 1GB)
$memorySizeBytes = [System.UInt64]($config.resources.networkOS.memoryMB * 1MB)
$dynamicMemory = $config.resources.networkOS.dynamicMemory
$generation = $config.resources.networkOS.generation
$bootDevice = $config.resources.networkOS.bootDevice

$EXTSwitchname01 = $config.switches.external.name
$CORSwitchname01 = $config.switches.core.name
$DMZSwitchname01 = $config.switches.dmz.name
$siteA_INTSwitchname01 = $config.switches.siteAInternal.name
$siteB_INTSwitchname01 = $config.switches.siteBInternal.name

$EXTNetworkAdapter01 = $config.networkAdapters.external
$CORNetworkAdapter01 = $config.networkAdapters.core
$DMZNetworkAdapter01 = $config.networkAdapters.dmz
$INTNetworkAdapter01 = $config.networkAdapters.internal

function New-NetworkOSVM {
    param(
        [string]$Name,
        [string]$SwitchName,
        [array]$ExtraAdapters = @()
    )

    New-VHD -Path "$vhdpath$Name.vhdx" -SizeBytes $vhdSizeBytes
    New-VM -Name $Name -MemoryStartupBytes $memorySizeBytes -VHDPath "$vhdpath$Name.vhdx" -Generation $generation -BootDevice $bootDevice
    Set-VMDvdDrive $Name -Path $imagepath

    if (-not $dynamicMemory) {
        Set-VMMemory -VMName $Name -DynamicMemoryEnabled $false -StartupBytes $memorySizeBytes
    }

    Add-VMNetworkAdapter -VMName $Name -Name $CORNetworkAdapter01
    Connect-VMNetworkAdapter -VMName $Name -Name $CORNetworkAdapter01 -SwitchName $CORSwitchname01

    foreach ($adapter in $ExtraAdapters) {
        $adapterName = $adapter.Name
        $adapterSwitch = $adapter.Switch
        Add-VMNetworkAdapter -VMName $Name -Name $adapterName
        Connect-VMNetworkAdapter -VMName $Name -Name $adapterName -SwitchName $adapterSwitch
    }
}

# External NetworkOS VMs: EXT, COR, DMZ
foreach ($vm in $externalVMs) {
    $extraAdapters = @(
        [PSCustomObject]@{ Name = $EXTNetworkAdapter01; Switch = $EXTSwitchname01 },
        [PSCustomObject]@{ Name = $DMZNetworkAdapter01; Switch = $DMZSwitchname01 }
    )
    New-NetworkOSVM -Name $vm -SwitchName $EXTSwitchname01 -ExtraAdapters $extraAdapters
}

# SiteA NetworkOS VMs: COR, INT
foreach ($vm in $siteAVMs) {
    $extraAdapters = @(
        [PSCustomObject]@{ Name = $INTNetworkAdapter01; Switch = $siteA_INTSwitchname01 }
    )
    New-NetworkOSVM -Name $vm -SwitchName $siteA_INTSwitchname01 -ExtraAdapters $extraAdapters
}

# SiteB NetworkOS VMs: COR, INT
foreach ($vm in $siteBVMs) {
    $extraAdapters = @(
        [PSCustomObject]@{ Name = $INTNetworkAdapter01; Switch = $siteB_INTSwitchname01 }
    )
    New-NetworkOSVM -Name $vm -SwitchName $siteB_INTSwitchname01 -ExtraAdapters $extraAdapters
}

Get-VM | Where-Object { $_.Name -like $config.filters.networkOS } | Start-VM
Get-VM

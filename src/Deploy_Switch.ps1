#Requires -RunAsAdministrator

# Load Hyper-V configuration from external JSON file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path (Split-Path -Parent $scriptDir) "config\hyperv-config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$EXTSwitchname01 = $config.switches.external.name
$CORSwitchname01 = $config.switches.core.name
$DMZSwitchname01 = $config.switches.dmz.name
$siteA_INTSwitchname01 = $config.switches.siteAInternal.name
$siteB_INTSwitchname01 = $config.switches.siteBInternal.name
$ExSW01_netadaptername = $config.switches.external.netAdapterName
$enableIov = $config.switches.external.enableIov

# External Switch
New-VMSwitch $EXTSwitchname01 -NetAdapterName $ExSW01_netadaptername -EnableIov $enableIov

# Core Switch
New-VMSwitch $CORSwitchname01 -SwitchType $config.switches.core.type

# DMZ Switch
New-VMSwitch $DMZSwitchname01 -SwitchType $config.switches.dmz.type

# Internal Switches
New-VMSwitch $siteA_INTSwitchname01 -SwitchType $config.switches.siteAInternal.type
New-VMSwitch $siteB_INTSwitchname01 -SwitchType $config.switches.siteBInternal.type

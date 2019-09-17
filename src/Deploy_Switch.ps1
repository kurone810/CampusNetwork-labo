# Parameter help description
param(
[string]
$EXTSwitchname01 = "EXTSW01",
$CORSwitchname01 = "CORSW01",
$DMZSwitchname01 = "DMZSW01",
$siteA_INTSwitchname01 = "siteA-INTSW01",
$siteB_INTSwitchname01 = "siteB-INTSW01",
$ExSW01_netadaptername = "Wi-Fi"
)

#External Switch
New-VMSwitch $EXTSwitchname01 -NetAdapterName $ExSW01_netadaptername -EnableIov $true

#CoreSwitch
New-VMSwitch $CORSwitchname01 -SwitchType Internal

#DMZSwitch
New-VMSwitch $DMZSwitchname01 -SwitchType Internal

#Internalswitch
New-VMSwitch $siteA_INTSwitchname01 -SwitchType Internal
New-VMSwitch $siteB_INTSwitchname01 -SwitchType Internal

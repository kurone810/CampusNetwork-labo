$Status = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
if($Status.State -eq "enabled"){
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}


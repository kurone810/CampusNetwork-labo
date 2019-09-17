param(
    #Centos Name Parameters ※Dependency
    $Dmz_VM01_name = "DmzCentOS01",
    $SiteA_VM01_name = "SiteACentOS01",
    $SiteA_VM02_name = "SiteACentOS02",
    $SiteB_VM01_name = "SiteBCentOS01",
    $SiteB_VM02_name = "SiteBCentOS02",

    #Vyos Name Parameters 
    $Ex_vyos01_name = "ExVyOS01",
    $Ex_vyos02_name = "ExVyOS02",
    $SiteA_vyos01_name = "SiteAVyOS01",
    $SiteA_vyos02_name = "SiteAVyOS02",
    $SiteB_vyos01_name = "SiteBVyOS01",

    #Switchname ※Dependency
    $DefaultSwitchname = "Default Switch",

    #Network Adapter  
    $DefaultNetworkAdapter = "ネットワーク アダプター"
)



#Create Centos NetworkAdapter And Connect
#Add-VMNetworkAdapter $Dmz_VM01_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $Dmz_VM01_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteA_VM01_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteA_VM01_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteA_VM02_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteA_VM02_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteB_VM01_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteB_VM01_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteB_VM02_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteB_VM02_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Create vyos NetworkAdapter And Connect

#Add-VMNetworkAdapter $Ex_vyos01_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $Ex_vyos01_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $Ex_vyos02_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $Ex_vyos02_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteA_vyos01_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteA_vyos01_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteA_vyos02_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteA_vyos02_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Add-VMNetworkAdapter $SiteB_vyos01_name -Name $DefaultNetworkAdapter
Connect-VMNetworkAdapter -VMName $SiteB_vyos01_name -Name $DefaultNetworkAdapter -SwitchName $DefaultSwitchname

#Get-VM | Where-Object {$_.Name -like "*CentOS*"} | Start-VM
#Get-VM

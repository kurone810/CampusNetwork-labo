param(
    #VYOS Deploy Parameters
    $vhdpath = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\",    
    $imagepath = "C:\ISO\CentOS-7-x86_64-DVD-1804.iso",
    $Dmz_VM01_name = "DmzCentOS01",
    $SiteA_VM01_name = "SiteACentOS01",
    $SiteA_VM02_name = "SiteACentOS02",
    $SiteB_VM01_name = "SiteBCentOS01",
    $SiteB_VM02_name = "SiteBCentOS02",

    #Resouces Parameters
    [System.UInt64]
    $init_ALL_VHDSize = 20GB,
    $init_Dmz_memorySize = 2048MB,
    $init_internal_memorySize = 2048MB,
    
    #Switchname ※Dependency
    $DMZSwitchname01 = "DMZSW01",
    $siteA_INTSwitchname01 = "siteA-INTSW01",
    $siteB_INTSwitchname01 = "siteB-INTSW01",

    #Network Adapter  
    $DMZNetworkAdapter01 = "DMZ-NIC01",
    $INTNetworkAdapter01 = "INT-NIC01"
)


#Create Virtual HDD
New-VHD -Path "$vhdpath$Dmz_VM01_name.vhdx" -SizeBytes $init_ALL_VHDSize

New-VHD -Path "$vhdpath$SiteA_VM01_name.vhdx" -SizeBytes $init_ALL_VHDSize

New-VHD -Path "$vhdpath$SiteA_VM02_name.vhdx" -SizeBytes $init_ALL_VHDSize

New-VHD -Path "$vhdpath$SiteB_VM01_name.vhdx" -SizeBytes $init_ALL_VHDSize

New-VHD -Path "$vhdpath$SiteB_VM02_name.vhdx" -SizeBytes $init_ALL_VHDSize

#Create VM
New-VM -Name $Dmz_VM01_name -MemoryStartupBytes $init_Dmz_memorySize `
-VHDPath "$vhdpath$Dmz_VM01_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteA_VM01_name -MemoryStartupBytes $init_internal_memorySize `
-VHDPath "$vhdpath$SiteA_VM01_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteA_VM02_name -MemoryStartupBytes $init_internal_memorySize `
-VHDPath "$vhdpath$SiteA_VM02_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteB_VM01_name -MemoryStartupBytes $init_internal_memorySize `
-VHDPath "$vhdpath$SiteB_VM01_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteB_VM02_name -MemoryStartupBytes $init_internal_memorySize `
-VHDPath "$vhdpath$SiteB_VM02_name.vhdx" `
-Generation 1 -BootDevice CD

#ISO-imageDrive-mount
Set-VMDvdDrive $Dmz_VM01_name -Path $imagepath

Set-VMDvdDrive $SiteA_VM01_name -Path $imagepath

Set-VMDvdDrive $SiteA_VM02_name -Path $imagepath

Set-VMDvdDrive $SiteB_VM01_name -Path $imagepath

Set-VMDvdDrive $SiteB_VM02_name -Path $imagepath

#Create NetworkAdapter And Connect
Add-VMNetworkAdapter $Dmz_VM01_name -Name $DMZNetworkAdapter01
Connect-VMNetworkAdapter -VMName $Dmz_VM01_name -Name $DMZNetworkAdapter01 -SwitchName $DMZSwitchname01

Add-VMNetworkAdapter $SiteA_VM01_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteA_VM01_name -Name $INTNetworkAdapter01 -SwitchName $siteA_INTSwitchname01

Add-VMNetworkAdapter $SiteA_VM02_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteA_VM02_name -Name $INTNetworkAdapter01 -SwitchName $siteA_INTSwitchname01

Add-VMNetworkAdapter $SiteB_VM01_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteB_VM01_name -Name $INTNetworkAdapter01 -SwitchName $siteB_INTSwitchname01

Add-VMNetworkAdapter $SiteB_VM02_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteB_VM02_name -Name $INTNetworkAdapter01 -SwitchName $siteB_INTSwitchname01


#Get-VM | Where-Object {$_.Name -like "*CentOS*"} | Start-VM
#Get-VM

param(
    #VYOS Deploy Parameters
    $vhdpath = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\",    
    $vyosimagepath = "C:\ISO\vyos-1.1.8-amd64.iso",
    $Ex_vyos01_name = "ExVyOS01-labo",
    $Ex_vyos02_name = "ExVyOS02-labo",
    $SiteA_vyos01_name = "SiteAVyOS01-labo",
    $SiteA_vyos02_name = "SiteAVyOS02-labo",
    $SiteB_vyos01_name = "SiteBVyOS01-labo",

    #Resouces Parameters
    [System.UInt64]
    $init_ALL_vyosVHDSize = 10GB,
    $init_External_vyosmemorySize = 256MB,
    $init_internal_vyosmemorySize = 256MB,
    
    #Switchname ※Dependency
    $EXTSwitchname01 = "EXTSW01",
    $CORSwitchname01 = "CORSW01",
    $DMZSwitchname01 = "DMZSW01",
    $siteA_INTSwitchname01 = "siteA-INTSW01",
    $siteB_INTSwitchname01 = "siteB-INTSW01",

    #Network Adapter  
    $EXTNetworkAdapter01 = "EXT-NIC01",
    $CORNetworkAdapter01 = "COR-NIC01",
    $DMZNetworkAdapter01 = "DMZ-NIC01",
    $INTNetworkAdapter01 = "INT-NIC01"
)


#Create Virtual HDD
New-VHD -Path "$vhdpath$Ex_vyos01_name.vhdx" -SizeBytes $init_ALL_vyosVHDSize

New-VHD -Path "$vhdpath$Ex_vyos02_name.vhdx" -SizeBytes $init_ALL_vyosVHDSize

New-VHD -Path "$vhdpath$SiteA_vyos01_name.vhdx" -SizeBytes $init_ALL_vyosVHDSize

New-VHD -Path "$vhdpath$SiteA_vyos02_name.vhdx" -SizeBytes $init_ALL_vyosVHDSize

New-VHD -Path "$vhdpath$SiteB_vyos01_name.vhdx" -SizeBytes $init_ALL_vyosVHDSize

#Create VM
New-VM -Name $Ex_vyos01_name -MemoryStartupBytes $init_External_vyosmemorySize `
-VHDPath "$vhdpath$Ex_vyos01_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $Ex_vyos02_name -MemoryStartupBytes $init_External_vyosmemorySize `
-VHDPath "$vhdpath$Ex_vyos02_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteA_vyos01_name -MemoryStartupBytes $init_Internal_vyosmemorySize `
-VHDPath "$vhdpath$SiteA_vyos01_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteA_vyos02_name -MemoryStartupBytes $init_Internal_vyosmemorySize `
-VHDPath "$vhdpath$SiteA_vyos02_name.vhdx" `
-Generation 1 -BootDevice CD

New-VM -Name $SiteB_vyos01_name -MemoryStartupBytes $init_Internal_vyosmemorySize `
-VHDPath "$vhdpath$SiteB_vyos01_name.vhdx" `
-Generation 1 -BootDevice CD

#ISO-imageDrive-mount
Set-VMDvdDrive $Ex_vyos01_name -Path $vyosimagepath

Set-VMDvdDrive $Ex_vyos02_name -Path $vyosimagepath

Set-VMDvdDrive $SiteA_vyos01_name -Path $vyosimagepath

Set-VMDvdDrive $SiteA_vyos02_name -Path $vyosimagepath

Set-VMDvdDrive $SiteB_vyos01_name -Path $vyosimagepath

#Create NetworkAdapter And Connect
Add-VMNetworkAdapter $Ex_vyos01_name -Name $EXTNetworkAdapter01
Add-VMNetworkAdapter $Ex_vyos01_name -Name $CORNetworkAdapter01
Add-VMNetworkAdapter $Ex_vyos01_name -Name $DMZNetworkAdapter01
Connect-VMNetworkAdapter -VMName $Ex_vyos01_name -Name $EXTNetworkAdapter01 -SwitchName $EXTSwitchname01
Connect-VMNetworkAdapter -VMName $Ex_vyos01_name -Name $CORNetworkAdapter01 -SwitchName $CORSwitchname01
Connect-VMNetworkAdapter -VMName $Ex_vyos01_name -Name $DMZNetworkAdapter01 -SwitchName $DMZSwitchname01

Add-VMNetworkAdapter $Ex_vyos02_name -Name $EXTNetworkAdapter01
Add-VMNetworkAdapter $Ex_vyos02_name -Name $CORNetworkAdapter01
Add-VMNetworkAdapter $Ex_vyos02_name -Name $DMZNetworkAdapter01
Connect-VMNetworkAdapter -VMName $Ex_vyos02_name -Name $EXTNetworkAdapter01 -SwitchName $EXTSwitchname01
Connect-VMNetworkAdapter -VMName $Ex_vyos02_name -Name $CORNetworkAdapter01 -SwitchName $CORSwitchname01
Connect-VMNetworkAdapter -VMName $Ex_vyos02_name -Name $DMZNetworkAdapter01 -SwitchName $DMZSwitchname01

Add-VMNetworkAdapter $SiteA_vyos01_name -Name $CORNetworkAdapter01
Add-VMNetworkAdapter $SiteA_vyos01_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteA_vyos01_name -Name $CORNetworkAdapter01 -SwitchName $CORSwitchname01
Connect-VMNetworkAdapter -VMName $SiteA_vyos01_name -Name $INTNetworkAdapter01 -SwitchName $siteA_INTSwitchname01

Add-VMNetworkAdapter $SiteA_vyos02_name -Name $CORNetworkAdapter01
Add-VMNetworkAdapter $SiteA_vyos02_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteA_vyos02_name -Name $CORNetworkAdapter01 -SwitchName $CORSwitchname01
Connect-VMNetworkAdapter -VMName $SiteA_vyos02_name -Name $INTNetworkAdapter01 -SwitchName $siteA_INTSwitchname01

Add-VMNetworkAdapter $SiteB_vyos01_name -Name $CORNetworkAdapter01
Add-VMNetworkAdapter $SiteB_vyos01_name -Name $INTNetworkAdapter01
Connect-VMNetworkAdapter -VMName $SiteB_vyos01_name -Name $CORNetworkAdapter01 -SwitchName $CORSwitchname01
Connect-VMNetworkAdapter -VMName $SiteB_vyos01_name -Name $INTNetworkAdapter01 -SwitchName $siteB_INTSwitchname01


Get-VM | Where-Object {$_.Name -like "*VyOS*"} | Start-VM
Get-VM

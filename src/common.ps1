#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    CampusNetwork-labo 蜈ｱ騾夐未謨ｰ繝｢繧ｸ繝･繝ｼ繝ｫ
.DESCRIPTION
    Hyper-V 繝ｩ繝懃腸蠅・・讒狗ｯ峨・蜑企勁縺ｫ菴ｿ逕ｨ縺吶ｋ蜈ｱ騾夐未謨ｰ繧貞ｮ夂ｾｩ縺励∪縺吶・
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 荳｡蟇ｾ蠢懊ｒ諠ｳ螳壹・
#>

# 險ｭ螳壹ヵ繧｡繧､繝ｫ繧・dot sourcing 縺励※隱ｭ縺ｿ霎ｼ繧
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.ps1"
if (-not (Test-Path -Path $ConfigPath)) {
    throw "險ｭ螳壹ヵ繧｡繧､繝ｫ縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ: $ConfigPath"
}
. $ConfigPath

# --- 繝ｭ繧ｰ蜃ｺ蜉幃未謨ｰ ---
function Write-LabLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )

    $ColorMap = @{
        Info    = "White"
        Success = "Green"
        Warning = "Yellow"
        Error   = "Red"
    }

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $ColorMap[$Level]
}

# --- 邂｡逅・・ｨｩ髯舌メ繧ｧ繝・け ---
function Test-Administrator {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

# --- Hyper-V 譛牙柑蛹悶メ繧ｧ繝・け ---
function Test-HyperVEnabled {
    [CmdletBinding()]
    param()

    try {
        $Feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -ErrorAction Stop
        return $Feature.State -eq "Enabled"
    }
    catch {
        # PowerShell 7 縺ｧ縺ｯ Get-WindowsOptionalFeature 縺御ｽｿ縺医↑縺・ｴ蜷医′縺ゅｋ
        Write-LabLog -Message "Get-WindowsOptionalFeature 縺ｧ縺ｮ遒ｺ隱阪↓螟ｱ謨励＠縺ｾ縺励◆縲・ISM 縺ｧ遒ｺ隱阪＠縺ｾ縺吶・ -Level Warning
        $DismOutput = dism /Online /Get-FeatureInfo /FeatureName:Microsoft-Hyper-V 2>&1
        return ($DismOutput -join "") -match "迥ｶ諷・: 譛牙柑" -or ($DismOutput -join "") -match "State : Enabled"
    }
}

# --- Hyper-V 譛牙柑蛹・---
function Enable-LabHyperV {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (Test-HyperVEnabled) {
        Write-LabLog -Message "Hyper-V 縺ｯ譌｢縺ｫ譛牙柑縺ｧ縺吶・ -Level Success
        return
    }

    Write-Host "[Hyper-V] Hyper-V 縺檎┌蜉ｹ縺ｧ縺吶よ怏蜉ｹ蛹悶＠縺ｾ縺吶°・・(y/n): " -ForegroundColor Yellow -NoNewline
    $Answer = Read-Host
    if ($Answer -ne "y") {
        Write-LabLog -Message "Hyper-V 縺ｮ譛牙柑蛹悶ｒ繧ｹ繧ｭ繝・・縺励∪縺励◆縲・ -Level Info
        return
    }

    if ($PSCmdlet.ShouldProcess("Microsoft-Hyper-V", "Enable-WindowsOptionalFeature")) {
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart -ErrorAction Stop | Out-Null
            Write-LabLog -Message "Hyper-V 繧呈怏蜉ｹ蛹悶＠縺ｾ縺励◆縲ょ・襍ｷ蜍輔′蠢・ｦ√↑蝣ｴ蜷医′縺ゅｊ縺ｾ縺吶・ -Level Success
        }
        catch {
            throw "Hyper-V 縺ｮ譛牙柑蛹悶↓螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- 螟夜Κ繧ｹ繧､繝・メ逕ｨ繝阪ャ繝医Ρ繝ｼ繧ｯ繧｢繝繝励ち繝ｼ驕ｸ謚・---
function Select-LabExternalNetAdapter {
    [CmdletBinding()]
    param()

    $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface -eq $true } |
        Select-Object -Property Name, InterfaceDescription, LinkSpeed

    if ($Adapters.Count -eq 0) {
        throw "Up 迥ｶ諷九・迚ｩ逅・ロ繝・ヨ繝ｯ繝ｼ繧ｯ繧｢繝繝励ち繝ｼ縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縲・
    }

    if ($Adapters.Count -eq 1) {
        Write-LabLog -Message "螟夜Κ繧ｹ繧､繝・メ逕ｨ繧｢繝繝励ち繝ｼ縺ｨ縺励※ $($Adapters[0].Name) 繧剃ｽｿ逕ｨ縺励∪縺吶・ -Level Info
        return $Adapters[0].Name
    }

    Write-LabLog -Message "隍・焚縺ｮ繝阪ャ繝医Ρ繝ｼ繧ｯ繧｢繝繝励ち繝ｼ縺梧､懷・縺輔ｌ縺ｾ縺励◆縲ょ､夜Κ繧ｹ繧､繝・メ縺ｫ菴ｿ逕ｨ縺吶ｋ繧｢繝繝励ち繝ｼ繧帝∈謚槭＠縺ｦ縺上□縺輔＞縲・ -Level Warning
    for ($i = 0; $i -lt $Adapters.Count; $i++) {
        Write-Host "[$i] $($Adapters[$i].Name) ($($Adapters[$i].InterfaceDescription), $($Adapters[$i].LinkSpeed))"
    }

    do {
        $Selected = Read-Host "逡ｪ蜿ｷ繧貞・蜉帙＠縺ｦ縺上□縺輔＞ (0-$($Adapters.Count - 1))"
    } while ($Selected -notmatch "^\d+$" -or [int]$Selected -lt 0 -or [int]$Selected -ge $Adapters.Count)

    return $Adapters[[int]$Selected].Name
}

# --- 繧ｹ繧､繝・メ菴懈・ ---
function New-LabVMSwitch {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [ValidateSet("External", "Internal", "Private")]
        [string]$SwitchType = "Internal",

        [string]$NetAdapterName
    )

    $Existing = Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue
    if ($Existing) {
        Write-LabLog -Message "繧ｹ繧､繝・メ '$Name' 縺ｯ譌｢縺ｫ蟄伜惠縺励∪縺吶ゅせ繧ｭ繝・・縺励∪縺吶・ -Level Warning
        return
    }

    if ($PSCmdlet.ShouldProcess($Name, "New-VMSwitch")) {
        try {
            if ($SwitchType -eq "External") {
                if ([string]::IsNullOrEmpty($NetAdapterName)) {
                    $NetAdapterName = Select-LabExternalNetAdapter
                }
                New-VMSwitch -Name $Name -NetAdapterName $NetAdapterName -AllowManagementOS $true -EnableIov $false -ErrorAction Stop | Out-Null
            }
            else {
                New-VMSwitch -Name $Name -SwitchType $SwitchType -ErrorAction Stop | Out-Null
            }
            Write-LabLog -Message "繧ｹ繧､繝・メ '$Name' ($SwitchType) 繧剃ｽ懈・縺励∪縺励◆縲・ -Level Success
        }
        catch {
            throw "繧ｹ繧､繝・メ '$Name' 縺ｮ菴懈・縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- VHD 菴懈・ ---
function New-LabVHD {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [uint64]$SizeBytes
    )

    $VhdPath = Join-Path -Path $script:LabVhdPath -ChildPath "$VMName.vhdx"

    if (Test-Path -Path $VhdPath) {
        Write-LabLog -Message "VHD '$VhdPath' 縺ｯ譌｢縺ｫ蟄伜惠縺励∪縺吶ゅせ繧ｭ繝・・縺励∪縺吶・ -Level Warning
        return $VhdPath
    }

    if ($PSCmdlet.ShouldProcess($VhdPath, "New-VHD")) {
        try {
            New-VHD -Path $VhdPath -SizeBytes $SizeBytes -Dynamic -ErrorAction Stop | Out-Null
            Write-LabLog -Message "VHD '$VhdPath' 繧剃ｽ懈・縺励∪縺励◆縲・ -Level Success
        }
        catch {
            throw "VHD '$VhdPath' 縺ｮ菴懈・縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }

    return $VhdPath
}

# --- VM 菴懈・ ---
function New-LabVM {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [uint64]$MemoryStartupBytes,

        [Parameter(Mandatory = $true)]
        [string]$VhdPath,

        [int]$Generation = 2
    )

    $Existing = Get-VM -Name $Name -ErrorAction SilentlyContinue
    if ($Existing) {
        Write-LabLog -Message "VM '$Name' 縺ｯ譌｢縺ｫ蟄伜惠縺励∪縺吶ゅせ繧ｭ繝・・縺励∪縺吶・ -Level Warning
        return
    }

    if (-not (Test-Path -Path $VhdPath)) {
        throw "VHD 縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ: $VhdPath"
    }

    if ($PSCmdlet.ShouldProcess($Name, "New-VM")) {
        try {
            $VM = New-VM -Name $Name -MemoryStartupBytes $MemoryStartupBytes -VHDPath $VhdPath -Generation $Generation -ErrorAction Stop
            Write-LabLog -Message "VM '$Name' (Generation $Generation) 繧剃ｽ懈・縺励∪縺励◆縲・ -Level Success

            # Generation 2 VM 縺ｮ蝣ｴ蜷医ヾecure Boot 繧堤┌蜉ｹ蛹厄ｼ・inux 繧ｲ繧ｹ繝医・莠呈鋤諤ｧ蜷台ｸ奇ｼ・
            if ($Generation -ge 2) {
                try {
                    Set-VMFirmware -VMName $Name -EnableSecureBoot Off -ErrorAction Stop
                    Write-LabLog -Message "VM '$Name' 縺ｮ Secure Boot 繧堤┌蜉ｹ蛹悶＠縺ｾ縺励◆縲・ -Level Info
                }
                catch {
                    Write-LabLog -Message "VM '$Name' 縺ｮ Secure Boot 辟｡蜉ｹ蛹悶↓螟ｱ謨励＠縺ｾ縺励◆: $_" -Level Warning
                }
            }
        }
        catch {
            throw "VM '$Name' 縺ｮ菴懈・縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- DVD/ISO 繝槭え繝ｳ繝・---
function Mount-LabIso {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$IsoPath
    )

    if (-not (Test-Path -Path $IsoPath)) {
        throw "ISO 繝輔ぃ繧､繝ｫ縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ: $IsoPath"
    }

    if ($PSCmdlet.ShouldProcess("$VMName -> $IsoPath", "Set-VMDvdDrive")) {
        try {
            Set-VMDvdDrive -VMName $VMName -Path $IsoPath -ErrorAction Stop
            Write-LabLog -Message "VM '$VMName' 縺ｫ ISO '$IsoPath' 繧偵・繧ｦ繝ｳ繝医＠縺ｾ縺励◆縲・ -Level Success
        }
        catch {
            throw "VM '$VMName' 縺ｸ縺ｮ ISO 繝槭え繝ｳ繝医↓螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- NIC 霑ｽ蜉 ---
function Add-LabVMNetworkAdapter {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$AdapterName
    )

    $Existing = Get-VMNetworkAdapter -VMName $VMName -Name $AdapterName -ErrorAction SilentlyContinue
    if ($Existing) {
        Write-LabLog -Message "VM '$VMName' 縺ｮ NIC '$AdapterName' 縺ｯ譌｢縺ｫ蟄伜惠縺励∪縺吶ゅせ繧ｭ繝・・縺励∪縺吶・ -Level Warning
        return
    }

    if ($PSCmdlet.ShouldProcess("$VMName - $AdapterName", "Add-VMNetworkAdapter")) {
        try {
            Add-VMNetworkAdapter -VMName $VMName -Name $AdapterName -ErrorAction Stop
            Write-LabLog -Message "VM '$VMName' 縺ｫ NIC '$AdapterName' 繧定ｿｽ蜉縺励∪縺励◆縲・ -Level Success
        }
        catch {
            throw "VM '$VMName' 縺ｸ縺ｮ NIC 霑ｽ蜉縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- NIC 謗･邯・---
function Connect-LabVMNetworkAdapter {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$AdapterName,

        [Parameter(Mandatory = $true)]
        [string]$SwitchName
    )

    if ($PSCmdlet.ShouldProcess("$VMName - $AdapterName -> $SwitchName", "Connect-VMNetworkAdapter")) {
        try {
            Connect-VMNetworkAdapter -VMName $VMName -Name $AdapterName -SwitchName $SwitchName -ErrorAction Stop
            Write-LabLog -Message "VM '$VMName' 縺ｮ NIC '$AdapterName' 繧偵せ繧､繝・メ '$SwitchName' 縺ｫ謗･邯壹＠縺ｾ縺励◆縲・ -Level Success
        }
        catch {
            throw "VM '$VMName' 縺ｮ NIC 謗･邯壹↓螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- VM 蛛懈ｭ｢ ---
function Stop-LabVM {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name,

        [switch]$Force
    )

    process {
        $VM = Get-VM -Name $Name -ErrorAction SilentlyContinue
        if (-not $VM) {
            Write-LabLog -Message "VM '$Name' 縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縲・ -Level Warning
            return
        }

        if ($VM.State -eq "Off") {
            Write-LabLog -Message "VM '$Name' 縺ｯ譌｢縺ｫ蛛懈ｭ｢縺励※縺・∪縺吶・ -Level Info
            return
        }

        if ($PSCmdlet.ShouldProcess($Name, "Stop-VM")) {
            try {
                if ($Force) {
                    Stop-VM -Name $Name -Force -ErrorAction Stop
                }
                else {
                    Stop-VM -Name $Name -ErrorAction Stop
                }
                Write-LabLog -Message "VM '$Name' 繧貞●豁｢縺励∪縺励◆縲・ -Level Success
            }
            catch {
                Write-LabLog -Message "VM '$Name' 縺ｮ蛛懈ｭ｢縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_" -Level Error
            }
        }
    }
}

# --- VM 蜑企勁 ---
function Remove-LabVM {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name
    )

    process {
        $VM = Get-VM -Name $Name -ErrorAction SilentlyContinue
        if (-not $VM) {
            Write-LabLog -Message "VM '$Name' 縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縲・ -Level Warning
            return
        }

        if ($PSCmdlet.ShouldProcess($Name, "Remove-VM")) {
            try {
                Remove-VM -Name $Name -Force -ErrorAction Stop
                Write-LabLog -Message "VM '$Name' 繧貞炎髯､縺励∪縺励◆縲・ -Level Success
            }
            catch {
                Write-LabLog -Message "VM '$Name' 縺ｮ蜑企勁縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_" -Level Error
            }
        }
    }
}

# --- VHD 蜑企勁 ---
function Remove-LabVHD {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$VMName
    )

    process {
        $VhdPath = Join-Path -Path $script:LabVhdPath -ChildPath "$VMName.vhdx"
        if (Test-Path -Path $VhdPath) {
            if ($PSCmdlet.ShouldProcess($VhdPath, "Remove-Item")) {
                try {
                    Remove-Item -Path $VhdPath -Force -ErrorAction Stop
                    Write-LabLog -Message "VHD '$VhdPath' 繧貞炎髯､縺励∪縺励◆縲・ -Level Success
                }
                catch {
                    Write-LabLog -Message "VHD '$VhdPath' 縺ｮ蜑企勁縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_" -Level Error
                }
            }
        }
        else {
            Write-LabLog -Message "VHD '$VhdPath' 縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縲・ -Level Warning
        }
    }
}

# --- cloud-init seed.iso 逕滓・ ---
function New-LabVyOSSeedIso {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [string]$TemplateDir = $script:VyOSCloudInitTemplateDir
    )

    $UserDataPath = Join-Path -Path $TemplateDir -ChildPath "user-data"
    $MetaDataPath = Join-Path -Path $TemplateDir -ChildPath "meta-data"

    if (-not (Test-Path -Path $UserDataPath)) {
        throw "user-data 繝・Φ繝励Ξ繝ｼ繝医′隕九▽縺九ｊ縺ｾ縺帙ｓ: $UserDataPath"
    }
    if (-not (Test-Path -Path $MetaDataPath)) {
        throw "meta-data 繝・Φ繝励Ξ繝ｼ繝医′隕九▽縺九ｊ縺ｾ縺帙ｓ: $MetaDataPath"
    }

    # 蜃ｺ蜉帛・繝・ぅ繝ｬ繧ｯ繝医Μ縺後↑縺代ｌ縺ｰ菴懈・
    $OutputDir = Split-Path -Path $OutputPath -Parent
    if (-not (Test-Path -Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }

    if (Test-Path -Path $OutputPath) {
        Write-LabLog -Message "seed.iso '$OutputPath' 縺ｯ譌｢縺ｫ蟄伜惠縺励∪縺吶ょ・逕滓・縺励∪縺吶・ -Level Warning
        Remove-Item -Path $OutputPath -Force
    }

    if ($PSCmdlet.ShouldProcess($OutputPath, "New-LabVyOSSeedIso")) {
        try {
            # oscdimg 縺後≠繧後・菴ｿ逕ｨ縲√↑縺代ｌ縺ｰ PowerShell + .NET 縺ｧ莉｣譖ｿ
            $Oscdimg = Get-Command -Name "oscdimg" -ErrorAction SilentlyContinue
            if ($Oscdimg) {
                $Arguments = "-n -d -h", $TemplateDir, $OutputPath
                & $Oscdimg.Source $Arguments 2>&1 | Out-Null
            }
            else {
                Write-LabLog -Message "oscdimg 縺瑚ｦ九▽縺九ｉ縺ｪ縺・◆繧√￣owerShell 縺ｧ ISO 繧堤函謌舌＠縺ｾ縺吶・ -Level Warning
                New-IsoFile -Source $TemplateDir -Path $OutputPath -Title "cidata"
            }
            Write-LabLog -Message "seed.iso '$OutputPath' 繧堤函謌舌＠縺ｾ縺励◆縲・ -Level Success
        }
        catch {
            throw "seed.iso 縺ｮ逕滓・縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_"
        }
    }
}

# --- ISO 繝輔ぃ繧､繝ｫ逕滓・陬懷勧髢｢謨ｰ・・scdimg 縺ｪ縺礼畑・・---
function New-IsoFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [string]$Title = "cidata"
    )

    # 邁｡譏鍋噪縺ｪ ISO 逕滓・: IMAPI2 繧剃ｽｿ逕ｨ
    $ImageMaster = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
    $ImageMaster.ChooseImageDefaultsForMediaType(12) | Out-Null  # MEDIA_TYPE_CDR
    $ImageMaster.VolumeName = $Title

    $Root = $ImageMaster.Root
    $Items = Get-ChildItem -Path $Source -File
    foreach ($Item in $Items) {
        $Root.AddTree($Item.FullName, $false) | Out-Null
    }

    $ImageMaster.CreateResultImage() | Out-Null
    $Stream = $ImageMaster.CreateResultImage().ImageStream

    $Buffer = New-Object byte[] -ArgumentList $Stream.Stat().cbSize
    $Stream.Read($Buffer, $Buffer.Length) | Out-Null
    [System.IO.File]::WriteAllBytes($Path, $Buffer)
}

# --- PowerShell Direct 縺ｧ VM 蜀・さ繝槭Φ繝牙ｮ溯｡・---
function Invoke-LabVMCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [object[]]$ArgumentList,

        [PSCredential]$Credential
    )

    if (-not $Credential) {
        $SecurePassword = ConvertTo-SecureString -String $script:WindowsServerLocalPassword -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $script:WindowsServerLocalAdmin, $SecurePassword
    }

    # VM 縺瑚ｵｷ蜍輔＠縺ｦ蠢懃ｭ泌庄閭ｽ縺ｫ縺ｪ繧九∪縺ｧ蠕・ｩ・
    $Timeout = 300
    $Elapsed = 0
    $Ready = $false
    while ($Elapsed -lt $Timeout) {
        try {
            $null = Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock { $env:COMPUTERNAME } -ErrorAction Stop
            $Ready = $true
            break
        }
        catch {
            Write-LabLog -Message "VM '$VMName' 縺ｮ PowerShell Direct 蠢懃ｭ斐ｒ蠕・ｩ滉ｸｭ... ($Elapsed / $Timeout 遘・" -Level Info
            Start-Sleep -Seconds 10
            $Elapsed += 10
        }
    }

    if (-not $Ready) {
        throw "VM '$VMName' 縺・PowerShell Direct 縺ｧ蠢懃ｭ斐＠縺ｾ縺帙ｓ縺ｧ縺励◆縲・
    }

    try {
        if ($ArgumentList) {
            return Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList -ErrorAction Stop
        }
        else {
            return Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock $ScriptBlock -ErrorAction Stop
        }
    }
    catch {
        throw "VM '$VMName' 縺ｸ縺ｮ繧ｳ繝槭Φ繝牙ｮ溯｡後↓螟ｱ謨励＠縺ｾ縺励◆: $_"
    }
}

# --- VM 蜀・〒繝輔ぃ繧､繝ｫ繧帝・鄂ｮ・・owerShell Direct・・---
function Copy-LabVMFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [PSCredential]$Credential
    )

    if (-not (Test-Path -Path $SourcePath)) {
        throw "繧ｳ繝斐・蜈・ヵ繧｡繧､繝ｫ縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ: $SourcePath"
    }

    $ScriptBlock = {
        param($Content, $Destination)
        $Directory = Split-Path -Path $Destination -Parent
        if (-not (Test-Path -Path $Directory)) {
            New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        }
        [System.IO.File]::WriteAllBytes($Destination, $Content)
    }

    $Bytes = [System.IO.File]::ReadAllBytes($SourcePath)
    Invoke-LabVMCommand -VMName $VMName -Credential $Credential -ScriptBlock $ScriptBlock -ArgumentList (, $Bytes), $DestinationPath
}

# --- 繧ｹ繧､繝・メ蜑企勁 ---
function Remove-LabVMSwitch {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name
    )

    process {
        $Switch = Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue
        if (-not $Switch) {
            Write-LabLog -Message "繧ｹ繧､繝・メ '$Name' 縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ縲・ -Level Warning
            return
        }

        if ($PSCmdlet.ShouldProcess($Name, "Remove-VMSwitch")) {
            try {
                Remove-VMSwitch -Name $Name -Force -ErrorAction Stop
                Write-LabLog -Message "繧ｹ繧､繝・メ '$Name' 繧貞炎髯､縺励∪縺励◆縲・ -Level Success
            }
            catch {
                Write-LabLog -Message "繧ｹ繧､繝・メ '$Name' 縺ｮ蜑企勁縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $_" -Level Error
            }
        }
    }
}


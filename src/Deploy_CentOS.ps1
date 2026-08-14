#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Linux サーバー VM を作成します。
.DESCRIPTION
    CentOS の後継ディストリビューション（AlmaLinux / Rocky Linux / CentOS Stream 等）
    用に Generation 2 VM を作成し、NIC を接続します。
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 両対応。
    ISO パスは config.ps1 の $script:LinuxIsoPath を参照します。
#>

$ErrorActionPreference = "Stop"

# 共通設定・関数を読み込み
$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== Linux VM の作成を開始します ===" -Level Info

    # ISO ファイル存在確認
    if (-not (Test-Path -Path $script:LinuxIsoPath)) {
        throw "Linux ISO が見つかりません: $($script:LinuxIsoPath)"
    }

    # VM 定義：名前、メモリ、接続する NIC とスイッチ
    $LinuxDefinitions = @(
        @{
            Name   = $script:DmzCentOSName
            Memory = $script:DmzLinuxMemory
            NICs   = @(
                @{ Name = $script:DmzNicName; Switch = $script:DMZSwitchName }
            )
        },
        @{
            Name   = $script:SiteACentOS01Name
            Memory = $script:IntLinuxMemory
            NICs   = @(
                @{ Name = $script:IntNicName; Switch = $script:SiteAIntSwitchName }
            )
        },
        @{
            Name   = $script:SiteACentOS02Name
            Memory = $script:IntLinuxMemory
            NICs   = @(
                @{ Name = $script:IntNicName; Switch = $script:SiteAIntSwitchName }
            )
        },
        @{
            Name   = $script:SiteBCentOS01Name
            Memory = $script:IntLinuxMemory
            NICs   = @(
                @{ Name = $script:IntNicName; Switch = $script:SiteBIntSwitchName }
            )
        },
        @{
            Name   = $script:SiteBCentOS02Name
            Memory = $script:IntLinuxMemory
            NICs   = @(
                @{ Name = $script:IntNicName; Switch = $script:SiteBIntSwitchName }
            )
        }
    )

    foreach ($Def in $LinuxDefinitions) {
        # VHD 作成
        $VhdPath = New-LabVHD -VMName $Def.Name -SizeBytes $script:LinuxVhdSize

        # VM 作成
        New-LabVM -Name $Def.Name -MemoryStartupBytes $Def.Memory -VhdPath $VhdPath -Generation $script:VmGeneration

        # ISO マウント
        Mount-LabIso -VMName $Def.Name -IsoPath $script:LinuxIsoPath

        # NIC 追加・接続
        foreach ($Nic in $Def.NICs) {
            Add-LabVMNetworkAdapter -VMName $Def.Name -AdapterName $Nic.Name
            Connect-LabVMNetworkAdapter -VMName $Def.Name -AdapterName $Nic.Name -SwitchName $Nic.Switch
        }
    }

    Get-VM | Where-Object { $_.Name -in $script:AllLinuxVMs } | Format-Table Name, State, Uptime, MemoryAssigned -AutoSize

    Write-LabLog -Message "=== Linux VM の作成が完了しました ===" -Level Success
    Write-LabLog -Message "注意: 各 VM の OS インストールは手動で行ってください。" -Level Warning
}
catch {
    Write-LabLog -Message "Linux VM 作成中にエラーが発生しました: $_" -Level Error
    exit 1
}

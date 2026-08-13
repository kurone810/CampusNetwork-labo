#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    VyOS ルーター VM を作成します。
.DESCRIPTION
    最新 VyOS 用に Generation 2 VM を作成し、NIC を接続します。
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 両対応。
    ISO パスは config.ps1 の $script:VyOSIsoPath を参照します。
#>

$ErrorActionPreference = "Stop"

# 共通設定・関数を読み込み
$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== VyOS VM の作成を開始します ===" -Level Info

    # ISO ファイル存在確認
    if (-not (Test-Path -Path $script:VyOSIsoPath)) {
        throw "VyOS ISO が見つかりません: $($script:VyOSIsoPath)"
    }

    # cloud-init seed.iso 生成（テンプレートがあれば）
    if (Test-Path -Path $script:VyOSCloudInitTemplateDir) {
        New-LabVyOSSeedIso -OutputPath $script:VyOSSeedIsoPath -TemplateDir $script:VyOSCloudInitTemplateDir
    }
    else {
        Write-LabLog -Message "cloud-init テンプレートが見つからないため、seed.iso は生成しません。" -Level Warning
    }

    # VM 定義：名前、メモリ、接続する NIC とスイッチ
    $VyOSDefinitions = @(
        @{
            Name   = $script:ExVyOS01Name
            Memory = $script:VyOSExtMemory
            NICs   = @(
                @{ Name = $script:ExtNicName; Switch = $script:EXTSwitchName },
                @{ Name = $script:CorNicName; Switch = $script:CORSwitchName },
                @{ Name = $script:DmzNicName; Switch = $script:DMZSwitchName }
            )
        },
        @{
            Name   = $script:ExVyOS02Name
            Memory = $script:VyOSExtMemory
            NICs   = @(
                @{ Name = $script:ExtNicName; Switch = $script:EXTSwitchName },
                @{ Name = $script:CorNicName; Switch = $script:CORSwitchName },
                @{ Name = $script:DmzNicName; Switch = $script:DMZSwitchName }
            )
        },
        @{
            Name   = $script:SiteAVyOS01Name
            Memory = $script:VyOSIntMemory
            NICs   = @(
                @{ Name = $script:CorNicName; Switch = $script:CORSwitchName },
                @{ Name = $script:IntNicName; Switch = $script:SiteAIntSwitchName }
            )
        },
        @{
            Name   = $script:SiteAVyOS02Name
            Memory = $script:VyOSIntMemory
            NICs   = @(
                @{ Name = $script:CorNicName; Switch = $script:CORSwitchName },
                @{ Name = $script:IntNicName; Switch = $script:SiteAIntSwitchName }
            )
        },
        @{
            Name   = $script:SiteBVyOS01Name
            Memory = $script:VyOSIntMemory
            NICs   = @(
                @{ Name = $script:CorNicName; Switch = $script:CORSwitchName },
                @{ Name = $script:IntNicName; Switch = $script:SiteBIntSwitchName }
            )
        }
    )

    foreach ($Def in $VyOSDefinitions) {
        # VHD 作成
        $VhdPath = New-LabVHD -VMName $Def.Name -SizeBytes $script:VyOSVhdSize

        # VM 作成
        New-LabVM -Name $Def.Name -MemoryStartupBytes $Def.Memory -VhdPath $VhdPath -Generation $script:VmGeneration

        # ISO マウント（VyOS インストール ISO）
        Mount-LabIso -VMName $Def.Name -IsoPath $script:VyOSIsoPath

        # cloud-init seed.iso を 2 台目の DVD ドライブとしてマウント
        if (Test-Path -Path $script:VyOSSeedIsoPath) {
            try {
                Add-VMDvdDrive -VMName $Def.Name -Path $script:VyOSSeedIsoPath -ErrorAction Stop
                Write-LabLog -Message "VM '$($Def.Name)' に seed.iso をマウントしました。" -Level Success
            }
            catch {
                Write-LabLog -Message "VM '$($Def.Name)' への seed.iso マウントに失敗しました: $_" -Level Warning
            }
        }

        # NIC 追加・接続
        foreach ($Nic in $Def.NICs) {
            Add-LabVMNetworkAdapter -VMName $Def.Name -AdapterName $Nic.Name
            Connect-LabVMNetworkAdapter -VMName $Def.Name -AdapterName $Nic.Name -SwitchName $Nic.Switch
        }
    }

    # 全 VyOS VM を起動
    $script:AllVyOSVMs | ForEach-Object {
        $VM = Get-VM -Name $_ -ErrorAction SilentlyContinue
        if ($VM -and $VM.State -ne "Running") {
            Start-VM -Name $_ -ErrorAction Stop
            Write-LabLog -Message "VM '$_' を起動しました。" -Level Success
        }
    }

    Get-VM | Where-Object { $_.Name -in $script:AllVyOSVMs } | Format-Table Name, State, Uptime, MemoryAssigned -AutoSize

    Write-LabLog -Message "=== VyOS VM の作成が完了しました ===" -Level Success
}
catch {
    Write-LabLog -Message "VyOS VM 作成中にエラーが発生しました: $_" -Level Error
    exit 1
}

#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Server VM を作成します。
.DESCRIPTION
    Windows Server 2022 / 2025 等の ISO から Generation 2 VM を作成し、
    NIC を接続します。OS インストールは手動、または unattend.xml で自動化してください。
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 両対応。
    ISO パスは config.ps1 の $script:WindowsServerIsoPath を参照します。
#>

$ErrorActionPreference = "Stop"

# 共通設定・関数を読み込み
$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== Windows Server VM の作成を開始します ===" -Level Info

    # ISO ファイル存在確認
    if (-not (Test-Path -Path $script:WindowsServerIsoPath)) {
        throw "Windows Server ISO が見つかりません: $($script:WindowsServerIsoPath)"
    }

    # VM 定義：名前、メモリ、接続する NIC とスイッチ
    $WindowsServerDefinitions = @(
        @{
            Name   = $script:SiteAADCName
            Memory = $script:WindowsServerMemory
            NICs   = @(
                @{ Name = $script:IntNicName; Switch = $script:SiteAIntSwitchName }
            )
        },
        @{
            Name   = $script:SiteBADCName
            Memory = $script:WindowsServerMemory
            NICs   = @(
                @{ Name = $script:IntNicName; Switch = $script:SiteBIntSwitchName }
            )
        },
        @{
            Name   = $script:DMZADCName
            Memory = $script:WindowsServerMemory
            NICs   = @(
                @{ Name = $script:DmzNicName; Switch = $script:DMZSwitchName }
            )
        }
    )

    foreach ($Def in $WindowsServerDefinitions) {
        # VHD 作成
        $VhdPath = New-LabVHD -VMName $Def.Name -SizeBytes $script:WindowsServerVhdSize

        # VM 作成
        New-LabVM -Name $Def.Name -MemoryStartupBytes $Def.Memory -VhdPath $VhdPath -Generation $script:VmGeneration

        # ISO マウント
        Mount-LabIso -VMName $Def.Name -IsoPath $script:WindowsServerIsoPath

        # NIC 追加・接続
        foreach ($Nic in $Def.NICs) {
            Add-LabVMNetworkAdapter -VMName $Def.Name -AdapterName $Nic.Name
            Connect-LabVMNetworkAdapter -VMName $Def.Name -AdapterName $Nic.Name -SwitchName $Nic.Switch
        }
    }

    # 全 Windows Server VM を起動
    $script:AllWindowsServerVMs | ForEach-Object {
        $VM = Get-VM -Name $_ -ErrorAction SilentlyContinue
        if ($VM -and $VM.State -ne "Running") {
            Start-VM -Name $_ -ErrorAction Stop
            Write-LabLog -Message "VM '$_' を起動しました。" -Level Success
        }
    }

    Get-VM | Where-Object { $_.Name -in $script:AllWindowsServerVMs } | Format-Table Name, State, Uptime, MemoryAssigned -AutoSize

    Write-LabLog -Message "=== Windows Server VM の作成が完了しました ===" -Level Success
    Write-LabLog -Message "OS インストール後、src/Configure-AD.ps1 を実行して AD 設定を自動化できます。" -Level Info
}
catch {
    Write-LabLog -Message "Windows Server VM 作成中にエラーが発生しました: $_" -Level Error
    exit 1
}

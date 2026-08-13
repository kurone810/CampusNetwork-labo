#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 VM を Default Switch に接続します。
.DESCRIPTION
    各 VM の既定 NIC を Default Switch に接続し、外部（インターネット）接続を可能にします。
    日本語 OS の場合は config.ps1 の $script:DefaultNicName を "ネットワーク アダプター" に変更してください。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== Default Switch への接続を開始します ===" -Level Info

    foreach ($VMName in $script:AllVMs) {
        $VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
        if (-not $VM) {
            Write-LabLog -Message "VM '$VMName' が見つかりません。" -Level Warning
            continue
        }

        $Nic = Get-VMNetworkAdapter -VMName $VMName -Name $script:DefaultNicName -ErrorAction SilentlyContinue
        if (-not $Nic) {
            Write-LabLog -Message "VM '$VMName' の NIC '$($script:DefaultNicName)' が見つかりません。" -Level Warning
            continue
        }

        Connect-VMNetworkAdapter -VMName $VMName -Name $script:DefaultNicName -SwitchName $script:DefaultSwitchName -ErrorAction Stop
        Write-LabLog -Message "VM '$VMName' を '$($script:DefaultSwitchName)' に接続しました。" -Level Success
    }
}
catch {
    Write-LabLog -Message "Default Switch 接続中にエラーが発生しました: $_" -Level Error
    exit 1
}

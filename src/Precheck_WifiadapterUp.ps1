#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    外部スイッチ用の物理ネットワークアダプターが Up 状態であるか確認します。
.DESCRIPTION
    Wi-Fi に限らず、Ethernet 等の Up 状態の物理アダプターを検出します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    $UpAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface -eq $true }

    if (-not $UpAdapters) {
        Write-LabLog -Message "Up 状態の物理ネットワークアダプターが見つかりません。ネットワーク接続を確認してください。" -Level Error
        exit 1
    }

    Write-LabLog -Message "Up 状態の物理アダプターを検出しました:" -Level Success
    $UpAdapters | ForEach-Object {
        Write-LabLog -Message "  - $($_.Name) ($($_.InterfaceDescription), $($_.LinkSpeed))" -Level Info
    }
}
catch {
    Write-LabLog -Message "ネットワークアダプター確認中にエラーが発生しました: $_" -Level Error
    exit 1
}

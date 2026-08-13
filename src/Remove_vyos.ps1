#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 VyOS VM を削除します。
.DESCRIPTION
    VM を停止してから削除します。VHD は別スクリプトで削除します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== VyOS VM の削除を開始します ===" -Level Info
    $script:AllVyOSVMs | Stop-LabVM -Force
    $script:AllVyOSVMs | Remove-LabVM
    Get-VM | Where-Object { $_.Name -in $script:AllVyOSVMs } | Format-Table Name, State -AutoSize
}
catch {
    Write-LabLog -Message "VyOS VM 削除中にエラーが発生しました: $_" -Level Error
    exit 1
}

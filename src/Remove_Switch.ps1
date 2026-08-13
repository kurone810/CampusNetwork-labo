#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    ラボ用仮想スイッチを削除します。
.DESCRIPTION
    Default Switch / 既定のスイッチ は削除しません。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== 仮想スイッチの削除を開始します ===" -Level Info
    $script:AllSwitches | Remove-LabVMSwitch
    Get-VMSwitch | Format-Table Name, SwitchType -AutoSize
}
catch {
    Write-LabLog -Message "スイッチ削除中にエラーが発生しました: $_" -Level Error
    exit 1
}

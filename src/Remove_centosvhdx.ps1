#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 Linux VM の VHD ファイルを削除します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== Linux VHD の削除を開始します ===" -Level Info
    $script:AllLinuxVMs | Remove-LabVHD
    Get-ChildItem -Path $script:LabVhdPath -Filter "*CentOS*-labo.vhdx" -ErrorAction SilentlyContinue |
        Format-Table Name, LastWriteTime -AutoSize
}
catch {
    Write-LabLog -Message "Linux VHD 削除中にエラーが発生しました: $_" -Level Error
    exit 1
}

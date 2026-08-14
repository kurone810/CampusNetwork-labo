#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 VyOS VM を停止します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== VyOS VM の停止を開始します ===" -Level Info
    $script:AllVyOSVMs | Stop-LabVM -Force
    Get-VM | Where-Object { $_.Name -in $script:AllVyOSVMs } | Format-Table Name, State -AutoSize
}
catch {
    Write-LabLog -Message "VyOS VM 停止中にエラーが発生しました: $_" -Level Error
    exit 1
}

#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 Linux VM を停止します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== Linux VM の停止を開始します ===" -Level Info
    $script:AllLinuxVMs | Stop-LabVM -Force
    Get-VM | Where-Object { $_.Name -in $script:AllLinuxVMs } | Format-Table Name, State -AutoSize
}
catch {
    Write-LabLog -Message "Linux VM 停止中にエラーが発生しました: $_" -Level Error
    exit 1
}

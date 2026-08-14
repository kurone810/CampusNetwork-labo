#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Hyper-V 機能が有効化されているか確認し、無効なら有効化します。
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 両対応。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Enable-LabHyperV
}
catch {
    Write-LabLog -Message "Hyper-V 有効化処理でエラーが発生しました: $_" -Level Error
    exit 1
}

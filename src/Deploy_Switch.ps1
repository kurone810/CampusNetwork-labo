#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Hyper-V 仮想スイッチを作成します。
.DESCRIPTION
    外部スイッチ・内部スイッチを作成します。
    外部スイッチの物理アダプターは自動検出・選択式です。
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 両対応。
#>

$ErrorActionPreference = "Stop"

# 共通設定・関数を読み込み
$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== 仮想スイッチの作成を開始します ===" -Level Info

    # 外部スイッチ
    New-LabVMSwitch -Name $script:EXTSwitchName -SwitchType External

    # 内部スイッチ
    New-LabVMSwitch -Name $script:CORSwitchName -SwitchType Internal
    New-LabVMSwitch -Name $script:DMZSwitchName -SwitchType Internal
    New-LabVMSwitch -Name $script:SiteAIntSwitchName -SwitchType Internal
    New-LabVMSwitch -Name $script:SiteBIntSwitchName -SwitchType Internal

    Write-LabLog -Message "=== 仮想スイッチの作成が完了しました ===" -Level Success
}
catch {
    Write-LabLog -Message "スイッチ作成中にエラーが発生しました: $_" -Level Error
    exit 1
}

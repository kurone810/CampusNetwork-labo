#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    VyOS 用 cloud-init seed.iso を生成します。
.DESCRIPTION
    src/cloud-init/vyos/ 以下の user-data / meta-data から seed.iso を生成し、
    C:\ISO\vyos-seed.iso として保存します。
    VyOS 1.3 / 1.4 系が cloud-init NoCloud データソースを読み込むことで、
    初回起動時にネットワーク設定・ユーザー設定を自動化できます。
.NOTES
    oscdimg が利用可能な場合はそれを使用し、ない場合は IMAPI2 を使用して ISO を生成します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== VyOS seed.iso の生成を開始します ===" -Level Info
    New-LabVyOSSeedIso -OutputPath $script:VyOSSeedIsoPath -TemplateDir $script:VyOSCloudInitTemplateDir
    Write-LabLog -Message "=== VyOS seed.iso の生成が完了しました ===" -Level Success
}
catch {
    Write-LabLog -Message "seed.iso 生成中にエラーが発生しました: $_" -Level Error
    exit 1
}

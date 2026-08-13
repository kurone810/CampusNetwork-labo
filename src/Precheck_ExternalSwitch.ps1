#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    既存の外部スイッチがないか確認します。
.DESCRIPTION
    外部スイッチが既に存在する場合、本ラボの外部スイッチ作成で競合する可能性があるため警告します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    $ExternalSwitches = Get-VMSwitch | Where-Object { $_.SwitchType -eq "External" }

    if ($ExternalSwitches) {
        Write-LabLog -Message "警告: 既存の外部スイッチが存在します。" -Level Warning
        $ExternalSwitches | ForEach-Object {
            Write-LabLog -Message "  - $($_.Name) ($($_.SwitchType))" -Level Warning
        }
        Write-LabLog -Message "既存の外部スイッチを削除するか、一時的に別種別のスイッチに切り替えてから実施してください。" -Level Warning
    }
    else {
        Write-LabLog -Message "ExternalSwitch: OK" -Level Success
    }
}
catch {
    Write-LabLog -Message "外部スイッチ確認中にエラーが発生しました: $_" -Level Error
    exit 1
}

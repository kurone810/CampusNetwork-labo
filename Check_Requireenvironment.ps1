#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    CampusNetwork-labo の前提条件を確認します。
.DESCRIPTION
    Hyper-V 有効化、外部スイッチの有無、物理ネットワークアダプターの Up 状態を確認します。
.NOTES
    管理者権限で実行してください。
#>

$ErrorActionPreference = "Stop"

# 実行ポリシーが制限されている場合は、現在のプロセスのみ RemoteSigned に緩和
$CurrentPolicy = Get-ExecutionPolicy -Scope Process
if ($CurrentPolicy -eq "Restricted" -or $CurrentPolicy -eq "AllSigned") {
    Write-Host "[ExecutionPolicy] 現在のプロセスの実行ポリシーを RemoteSigned に設定します。" -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
}

$SrcPath = Join-Path -Path $PSScriptRoot -ChildPath "src"

$Steps = @(
    "Enable_hyperv.ps1",
    "Precheck_ExternalSwitch.ps1",
    "Precheck_WifiadapterUp.ps1"
)

foreach ($Step in $Steps) {
    $ScriptPath = Join-Path -Path $SrcPath -ChildPath $Step
    if (-not (Test-Path -Path $ScriptPath)) {
        throw "スクリプトが見つかりません: $ScriptPath"
    }

    Write-Host "`n>>> $Step を実行します" -ForegroundColor Cyan
    & $ScriptPath

    if ($LASTEXITCODE -ne 0) {
        throw "$Step の実行に失敗しました (ExitCode: $LASTEXITCODE)"
    }
}

Write-Host "`n=== 前提条件の確認が完了しました ===" -ForegroundColor Green

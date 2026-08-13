#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    CampusNetwork-labo 環境を削除します。
.DESCRIPTION
    VM、VHD、仮想スイッチを順番に削除します。
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
    "Stop_windows.ps1",
    "Stop_centos.ps1",
    "Stop_vyos.ps1",
    "Remove_windows.ps1",
    "Remove_centos.ps1",
    "Remove_vyos.ps1",
    "Remove_windowsvhdx.ps1",
    "Remove_centosvhdx.ps1",
    "Remove_vyosvhdx.ps1",
    "Remove_Switch.ps1"
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

Write-Host "`n=== CampusNetwork-labo の削除が完了しました ===" -ForegroundColor Green

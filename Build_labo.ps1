#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    CampusNetwork-labo 環境を構築します。
.DESCRIPTION
    仮想スイッチ、VyOS VM、Linux VM を順番に作成・起動します。
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
    "Deploy_Switch.ps1",
    "Deploy_VyOS.ps1",
    "Deploy_CentOS.ps1",
    "Deploy_WindowsServer.ps1",
    "Start_vyos.ps1",
    "Start_centos.ps1",
    "Start_windows.ps1"
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

Write-Host "`n=== CampusNetwork-labo の構築が完了しました ===" -ForegroundColor Green

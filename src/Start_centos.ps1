#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 Linux VM を起動します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== Linux VM の起動を開始します ===" -Level Info

    $script:AllLinuxVMs | ForEach-Object {
        $VM = Get-VM -Name $_ -ErrorAction SilentlyContinue
        if (-not $VM) {
            Write-LabLog -Message "VM '$_' が見つかりません。" -Level Warning
            return
        }
        if ($VM.State -eq "Running") {
            Write-LabLog -Message "VM '$_' は既に実行中です。" -Level Info
        }
        else {
            Start-VM -Name $_ -ErrorAction Stop
            Write-LabLog -Message "VM '$_' を起動しました。" -Level Success
        }
    }

    Get-VM | Where-Object { $_.Name -in $script:AllLinuxVMs } | Format-Table Name, State, Uptime -AutoSize
}
catch {
    Write-LabLog -Message "Linux VM 起動中にエラーが発生しました: $_" -Level Error
    exit 1
}

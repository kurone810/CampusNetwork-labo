#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 VyOS VM から DVD/ISO を取り外します。
.DESCRIPTION
    OS インストール後に ISO をアンマウントする場合に使用します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== VyOS VM の DVD 取り外しを開始します ===" -Level Info

    foreach ($VMName in $script:AllVyOSVMs) {
        $VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
        if (-not $VM) {
            Write-LabLog -Message "VM '$VMName' が見つかりません。" -Level Warning
            continue
        }

        if ($VM.State -ne "Off") {
            Stop-VM -Name $VMName -Force -ErrorAction Stop
            Write-LabLog -Message "VM '$VMName' を停止しました。" -Level Info
        }

        $DvdDrive = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
        if ($DvdDrive -and $DvdDrive.Path) {
            Set-VMDvdDrive -VMName $VMName -Path $null -ErrorAction Stop
            Write-LabLog -Message "VM '$VMName' から DVD を取り外しました。" -Level Success
        }
        else {
            Write-LabLog -Message "VM '$VMName' に DVD はマウントされていません。" -Level Info
        }
    }
}
catch {
    Write-LabLog -Message "DVD 取り外し中にエラーが発生しました: $_" -Level Error
    exit 1
}

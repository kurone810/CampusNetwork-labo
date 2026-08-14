#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 Windows Server VM を起動します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

$script:AllWindowsServerVMs | ForEach-Object {
    $VM = Get-VM -Name $_ -ErrorAction SilentlyContinue
    if ($VM -and $VM.State -ne "Running") {
        Start-VM -Name $_ -ErrorAction Stop
        Write-LabLog -Message "VM '$_' を起動しました。" -Level Success
    }
    else {
        Write-LabLog -Message "VM '$_' は既に起動しているか、存在しません。" -Level Info
    }
}

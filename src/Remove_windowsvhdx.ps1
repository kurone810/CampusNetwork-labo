#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 Windows Server VM の VHD を削除します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

$script:AllWindowsServerVMs | Remove-LabVHD

#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    全 Windows Server VM を停止します。
#>

$ErrorActionPreference = "Stop"

$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

$script:AllWindowsServerVMs | Stop-LabVM -Force

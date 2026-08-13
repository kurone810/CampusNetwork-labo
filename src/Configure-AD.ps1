#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Server VM 内で Active Directory のサイト間構成を自動化します。
.DESCRIPTION
    PowerShell Direct を使用して、Hyper-V ホスト側から VM 内にコマンドを流し込みます。
    1. SiteA-ADC にフォレストを構築
    2. SiteB-ADC / DMZ-ADC を追加 DC としてプロモート
    3. サイト、サブネット、サイトリンクを構成
.NOTES
    VM 内の OS インストールが完了し、PowerShell リモート処理が有効になっている必要があります。
    デフォルトでは config.ps1 のローカル Administrator 資格情報を使用します。
#>

$ErrorActionPreference = "Stop"

# 共通設定・関数を読み込み
$CommonPath = Join-Path -Path $PSScriptRoot -ChildPath "common.ps1"
. $CommonPath

try {
    Write-LabLog -Message "=== AD サイト間構成の自動化を開始します ===" -Level Info

    # 対象 VM が存在するか確認
    foreach ($VMName in $script:AllWindowsServerVMs) {
        $VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
        if (-not $VM) {
            throw "VM '$VMName' が見つかりません。先に src/Deploy_WindowsServer.ps1 を実行してください。"
        }
        if ($VM.State -ne "Running") {
            Write-LabLog -Message "VM '$VMName' を起動します。" -Level Info
            Start-VM -Name $VMName -ErrorAction Stop
        }
    }

    # --- 1. SiteA-ADC にフォレストを構築 ---
    Write-LabLog -Message "SiteA-ADC ($($script:SiteAADCName)) にフォレストを構築します。" -Level Info
    $ForestScript = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "templates\ad\Install-ADDSForest.ps1") -Raw
    $ForestScriptBlock = [scriptblock]::Create($ForestScript)

    Invoke-LabVMCommand `
        -VMName $script:SiteAADCName `
        -ScriptBlock $ForestScriptBlock `
        -ArgumentList $script:ADDomainName, $script:ADNetBIOSName, $script:ADSafeModePassword, $script:ADSiteAName

    Write-LabLog -Message "SiteA-ADC の再起動を待機します。" -Level Info
    Start-Sleep -Seconds 60
    Invoke-LabVMCommand -VMName $script:SiteAADCName -ScriptBlock { $env:COMPUTERNAME }
    Write-LabLog -Message "SiteA-ADC が再起動しました。" -Level Success

    # --- 2. SiteB-ADC / DMZ-ADC を追加 DC としてプロモート ---
    foreach ($DC in @(
        @{ Name = $script:SiteBADCName; Site = $script:ADSiteBName },
        @{ Name = $script:DMZADCName; Site = $script:ADDMZSiteName }
    )) {
        Write-LabLog -Message "$($DC.Name) を追加 DC としてプロモートします。" -Level Info
        $DCScript = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "templates\ad\Install-ADDSDomainController.ps1") -Raw
        $DCScriptBlock = [scriptblock]::Create($DCScript)

        Invoke-LabVMCommand `
            -VMName $DC.Name `
            -ScriptBlock $DCScriptBlock `
            -ArgumentList $script:ADDomainName, $script:ADSafeModePassword, $DC.Site

        Write-LabLog -Message "$($DC.Name) の再起動を待機します。" -Level Info
        Start-Sleep -Seconds 60
        Invoke-LabVMCommand -VMName $DC.Name -ScriptBlock { $env:COMPUTERNAME }
        Write-LabLog -Message "$($DC.Name) が再起動しました。" -Level Success
    }

    # --- 3. サイト、サブネット、サイトリンクを構成 ---
    Write-LabLog -Message "AD サイト、サブネット、サイトリンクを構成します。" -Level Info
    $SiteScript = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "templates\ad\Configure-ADSites.ps1") -Raw
    $SiteScriptBlock = [scriptblock]::Create($SiteScript)

    Invoke-LabVMCommand `
        -VMName $script:SiteAADCName `
        -ScriptBlock $SiteScriptBlock `
        -ArgumentList $script:ADSiteAName, $script:ADSiteBName, $script:ADDMZSiteName, `
            $script:ADReplicationSubnetSiteA, $script:ADReplicationSubnetSiteB, $script:ADReplicationSubnetDMZ

    Write-LabLog -Message "=== AD サイト間構成の自動化が完了しました ===" -Level Success
}
catch {
    Write-LabLog -Message "AD 構成中にエラーが発生しました: $_" -Level Error
    exit 1
}

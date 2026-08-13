#requires -Version 5.1
<#
.SYNOPSIS
    CampusNetwork-labo 共通設定ファイル
.DESCRIPTION
    Hyper-V 上に構築するラボ環境の VM名・スイッチ名・リソース・ISOパスなどを一元管理します。
    環境に合わせて各変数を変更してください。
.NOTES
    Windows 11 / Windows PowerShell 5.1 / PowerShell 7 両対応を想定。
#>

# 管理者権限チェック
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "このスクリプトは管理者権限で実行してください。"
}

# --- パス設定 ---
$script:LabVhdPath = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
$script:LabIsoPath = "C:\ISO"

# --- OS イメージ設定 ---
# 実際の ISO ファイル名に合わせて変更してください。
$script:VyOSIsoName = "vyos-1.4-rolling-latest-amd64.iso"   # 最新 VyOS Rolling / LTS
$script:LinuxIsoName = "AlmaLinux-9-latest-x86_64-dvd.iso"  # AlmaLinux / Rocky Linux / CentOS Stream 等
$script:WindowsServerIsoName = "WindowsServer2022.iso"      # Windows Server 2022 / 2025 等

$script:VyOSIsoPath = Join-Path -Path $script:LabIsoPath -ChildPath $script:VyOSIsoName
$script:LinuxIsoPath = Join-Path -Path $script:LabIsoPath -ChildPath $script:LinuxIsoName
$script:WindowsServerIsoPath = Join-Path -Path $script:LabIsoPath -ChildPath $script:WindowsServerIsoName

# --- Windows Server 設定 ---
$script:WindowsServerLocalAdmin = "Administrator"
$script:WindowsServerLocalPassword = "P@ssw0rd!"   # 検証用。本番環境では変更してください。
$script:WindowsServerProductKey = ""                # 必要に応じてプロダクトキーを指定
$script:WindowsServerVhdSize = 40GB
$script:WindowsServerMemory = 4096MB

# --- Active Directory 設定 ---
$script:ADDomainName = "labo.local"
$script:ADNetBIOSName = "LABO"
$script:ADSafeModePassword = "P@ssw0rd!"            # DSRM パスワード（検証用）
$script:ADSiteAName = "SiteA"
$script:ADSiteBName = "SiteB"
$script:ADDMZSiteName = "DMZ"
$script:ADReplicationSubnetSiteA = "10.1.0.0/16"
$script:ADReplicationSubnetSiteB = "10.2.0.0/16"
$script:ADReplicationSubnetDMZ = "192.168.10.0/24"

# --- VyOS cloud-init 設定 ---
$script:VyOSSeedIsoName = "vyos-seed.iso"
$script:VyOSSeedIsoPath = Join-Path -Path $script:LabIsoPath -ChildPath $script:VyOSSeedIsoName
$script:VyOSDefaultUser = "vyos"
$script:VyOSDefaultPassword = "vyos"   # 検証用。本番環境では変更してください。
$script:VyOSCloudInitTemplateDir = Join-Path -Path $PSScriptRoot -ChildPath "cloud-init\vyos"

# --- VM 世代設定 ---
# Generation 2 を推奨（UEFI、Secure Boot 無効が必要なゲストOSもあります）
$script:VmGeneration = 2

# --- スイッチ設定 ---
$script:EXTSwitchName = "EXTSW01"
$script:CORSwitchName = "CORSW01"
$script:DMZSwitchName = "DMZSW01"
$script:SiteAIntSwitchName = "siteA-INTSW01"
$script:SiteBIntSwitchName = "siteB-INTSW01"
$script:DefaultSwitchName = "Default Switch"

# --- ネットワークアダプター名 ---
$script:ExtNicName = "EXT-NIC01"
$script:CorNicName = "COR-NIC01"
$script:DmzNicName = "DMZ-NIC01"
$script:IntNicName = "INT-NIC01"
$script:DefaultNicName = "Network Adapter"   # 英語OS。日本語OSの場合は "ネットワーク アダプター"

# --- VM 名設定 ---
$script:ExVyOS01Name = "ExVyOS01-labo"
$script:ExVyOS02Name = "ExVyOS02-labo"
$script:SiteAVyOS01Name = "SiteAVyOS01-labo"
$script:SiteAVyOS02Name = "SiteAVyOS02-labo"
$script:SiteBVyOS01Name = "SiteBVyOS01-labo"

$script:DmzCentOSName = "DmzCentOS01-labo"
$script:SiteACentOS01Name = "SiteACentOS01-labo"
$script:SiteACentOS02Name = "SiteACentOS02-labo"
$script:SiteBCentOS01Name = "SiteBCentOS01-labo"
$script:SiteBCentOS02Name = "SiteBCentOS02-labo"

$script:SiteAADCName = "SiteA-ADC-labo"      # SiteA の最初の DC
$script:SiteBADCName = "SiteB-ADC-labo"      # SiteB の追加 DC
$script:DMZADCName = "DMZ-ADC-labo"          # DMZ の追加 DC（オプション）

# --- リソース設定 ---
$script:VyOSVhdSize = 10GB
$script:VyOSExtMemory = 512MB
$script:VyOSIntMemory = 512MB

$script:LinuxVhdSize = 20GB
$script:DmzLinuxMemory = 2048MB
$script:IntLinuxMemory = 2048MB

# --- VM 定義リスト ---
# 一括作成・削除・起動・停止に使用
$script:AllVyOSVMs = @(
    $script:ExVyOS01Name
    $script:ExVyOS02Name
    $script:SiteAVyOS01Name
    $script:SiteAVyOS02Name
    $script:SiteBVyOS01Name
)

$script:AllLinuxVMs = @(
    $script:DmzCentOSName
    $script:SiteACentOS01Name
    $script:SiteACentOS02Name
    $script:SiteBCentOS01Name
    $script:SiteBCentOS02Name
)

$script:AllWindowsServerVMs = @(
    $script:SiteAADCName
    $script:SiteBADCName
    $script:DMZADCName
)

$script:AllVMs = $script:AllVyOSVMs + $script:AllLinuxVMs + $script:AllWindowsServerVMs

# --- スイッチ定義リスト ---
$script:AllSwitches = @(
    $script:EXTSwitchName
    $script:CORSwitchName
    $script:DMZSwitchName
    $script:SiteAIntSwitchName
    $script:SiteBIntSwitchName
)

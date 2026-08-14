# このスクリプトは VM 内で実行されます。
# サイト、サブネット、サイトリンクを構成します。
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteAName,

    [Parameter(Mandatory = $true)]
    [string]$SiteBName,

    [Parameter(Mandatory = $true)]
    [string]$DMZSiteName,

    [Parameter(Mandatory = $true)]
    [string]$SubnetSiteA,

    [Parameter(Mandatory = $true)]
    [string]$SubnetSiteB,

    [Parameter(Mandatory = $true)]
    [string]$SubnetDMZ
)

$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

# サイト作成
foreach ($Site in @($SiteAName, $SiteBName, $DMZSiteName)) {
    $Existing = Get-ADReplicationSite -Filter { Name -eq $Site } -ErrorAction SilentlyContinue
    if (-not $Existing) {
        New-ADReplicationSite -Name $Site -Description "Created by CampusNetwork-labo"
        Write-Host "サイト '$Site' を作成しました。"
    }
    else {
        Write-Host "サイト '$Site' は既に存在します。"
    }
}

# サブネット作成・サイト紐付け
$SubnetMap = @{
    $SubnetSiteA = $SiteAName
    $SubnetSiteB = $SiteBName
    $SubnetDMZ   = $DMZSiteName
}

foreach ($Subnet in $SubnetMap.Keys) {
    $Existing = Get-ADReplicationSubnet -Filter { Name -eq $Subnet } -ErrorAction SilentlyContinue
    if (-not $Existing) {
        New-ADReplicationSubnet -Name $Subnet -Site $SubnetMap[$Subnet] -Description "Created by CampusNetwork-labo"
        Write-Host "サブネット '$Subnet' をサイト '$($SubnetMap[$Subnet])' に紐付けました。"
    }
    else {
        Write-Host "サブネット '$Subnet' は既に存在します。"
    }
}

# サイト間リンク作成
$LinkName = "$SiteAName-$SiteBName"
$ExistingLink = Get-ADReplicationSiteLink -Filter { Name -eq $LinkName } -ErrorAction SilentlyContinue
if (-not $ExistingLink) {
    New-ADReplicationSiteLink -Name $LinkName -SitesIncluded $SiteAName, $SiteBName -Cost 100 -ReplicationFrequencyInMinutes 15 -Description "Created by CampusNetwork-labo"
    Write-Host "サイトリンク '$LinkName' を作成しました。"
}
else {
    Write-Host "サイトリンク '$LinkName' は既に存在します。"
}

# 必要に応じて DMZ サイトとのリンクも作成
$DMZLinkName = "$SiteAName-$DMZSiteName"
$ExistingDMZLink = Get-ADReplicationSiteLink -Filter { Name -eq $DMZLinkName } -ErrorAction SilentlyContinue
if (-not $ExistingDMZLink) {
    New-ADReplicationSiteLink -Name $DMZLinkName -SitesIncluded $SiteAName, $DMZSiteName -Cost 200 -ReplicationFrequencyInMinutes 30 -Description "Created by CampusNetwork-labo"
    Write-Host "サイトリンク '$DMZLinkName' を作成しました。"
}
else {
    Write-Host "サイトリンク '$DMZLinkName' は既に存在します。"
}

Write-Host "AD サイト構成が完了しました。"

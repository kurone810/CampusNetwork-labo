# このスクリプトは VM 内で実行されます。
# フォレスト/ドメインの最初の DC を構築します。
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName,

    [Parameter(Mandatory = $true)]
    [string]$NetBIOSName,

    [Parameter(Mandatory = $true)]
    [string]$SafeModePassword,

    [string]$SiteName = "Default-First-Site-Name"
)

$ErrorActionPreference = "Stop"

# AD DS 役割と管理ツールをインストール
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart:$false

# セーフモードパスワードを SecureString に変換
$SecurePassword = ConvertTo-SecureString -String $SafeModePassword -AsPlainText -Force

# フォレストを構築
$Params = @{
    DomainName                    = $DomainName
    DomainNetbiosName             = $NetBIOSName
    ForestMode                    = "WinThreshold"
    DomainMode                    = "WinThreshold"
    InstallDns                    = $true
    CreateDnsDelegation           = $false
    DatabasePath                  = "C:\Windows\NTDS"
    LogPath                       = "C:\Windows\NTDS"
    SysvolPath                    = "C:\Windows\SYSVOL"
    NoRebootOnCompletion          = $false
    SafeModeAdministratorPassword = $SecurePassword
    Force                         = $true
}

Install-ADDSForest @Params

# サイト名を変更（必要に応じて）
if ($SiteName -ne "Default-First-Site-Name") {
    Rename-ADObject -Identity (Get-ADReplicationSite -Identity "Default-First-Site-Name").DistinguishedName -NewName $SiteName
}

# このスクリプトは VM 内で実行されます。
# 既存ドメインに追加 DC としてプロモートします。
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName,

    [Parameter(Mandatory = $true)]
    [string]$SafeModePassword,

    [Parameter(Mandatory = $true)]
    [string]$SiteName
)

$ErrorActionPreference = "Stop"

# AD DS 役割と管理ツールをインストール
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart:$false

# セーフモードパスワードを SecureString に変換
$SecurePassword = ConvertTo-SecureString -String $SafeModePassword -AsPlainText -Force

# ドメイン参加用の資格情報（ローカル Administrator と同じパスワードを使用）
$AdminUser = "$DomainName\Administrator"
$SecureAdminPassword = ConvertTo-SecureString -String $SafeModePassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUser, $SecureAdminPassword

# 追加 DC としてプロモート
$Params = @{
    DomainName                    = $DomainName
    SiteName                      = $SiteName
    InstallDns                    = $true
    NoGlobalCatalog               = $false
    DatabasePath                  = "C:\Windows\NTDS"
    LogPath                       = "C:\Windows\NTDS"
    SysvolPath                    = "C:\Windows\SYSVOL"
    NoRebootOnCompletion          = $false
    SafeModeAdministratorPassword = $SecurePassword
    Credential                    = $Credential
    Force                         = $true
}

Install-ADDSDomainController @Params

# 概要

高スペックな Windows 11 Pro（または Windows 10 Pro）の PC があれば、Hyper-V 上に以下のような CampusNetwork を模したラボ物理構成を自動で作成する PowerShell スクリプトです。

![images](./images/CampusNetwork-images.jpg)

自宅にサーバーラックを導入しなくても、OSPF 等の動的ルーティングに伴う切り替えや、ネットワークスペシャリスト試験などで問われる技術要素の動作確認を実施したい場合に、構成のスクラップ＆ビルドを実施できます。

## 主な変更点（Windows 11 / 最新 OS 対応版）

- **共通設定ファイル** `src/config.ps1` を導入し、VM 名・スイッチ名・ISO パス・リソースを一元管理
- **共通関数ファイル** `src/common.ps1` を導入し、VM/VHD/スイッチの作成・削除を関数化
- **PowerShell 7 / Windows PowerShell 5.1 両対応**（Hyper-V 有効化確認は DISM フォールバック対応）
- **管理者権限チェック** を各スクリプトに追加（`#requires -RunAsAdministrator`）
- **Wi-Fi 決め打ちを廃止**し、外部スイッチ用の物理アダプターを自動検出・選択式に
- **Generation 2 VM** を採用（UEFI 対応）
- **OS を最新化**: CentOS 7 → AlmaLinux / Rocky Linux / CentOS Stream 等、VyOS 1.1.8 → VyOS 1.4 Rolling / LTS、Windows Server 2022 / 2025 対応
- **Active Directory サイト間構成の自動化**: PowerShell Direct を使用し、Hyper-V ホスト側から VM 内に AD 設定を流し込み
- **エラーハンドリング・ログ出力**を強化
- **ルートスクリプト**を `Start-Process` 呼び出しからシンプルな `&` 呼び出しに変更

## 前提事項

- Windows 11 Pro または Windows 10 Pro（Hyper-V が利用可能なエディション）
- 管理者権限で PowerShell を実行すること
- 推奨メモリ空き容量: **10 GiB 以上**
- 推奨空きディスク容量: **50 GB 以上**

## 準備

1. `C:\ISO` ディレクトリを作成し、以下の ISO イメージを配置してください。
   - VyOS: `vyos-1.4-rolling-latest-amd64.iso`（またはお使いのバージョン）
   - Linux: `AlmaLinux-9-latest-x86_64-dvd.iso`（Rocky Linux / CentOS Stream 等でも可）
   - Windows Server: `WindowsServer2022.iso`（2025 等でも可）
2. `src/config.ps1` の以下の変数を、実際の ISO ファイル名に合わせて変更してください。
   ```powershell
   $script:VyOSIsoName = "vyos-1.4-rolling-latest-amd64.iso"
   $script:LinuxIsoName = "AlmaLinux-9-latest-x86_64-dvd.iso"
   $script:WindowsServerIsoName = "WindowsServer2022.iso"
   ```
   Windows Server のローカル Administrator パスワードや AD 設定も `src/config.ps1` で変更できます。
3. 日本語版 Windows をお使いの場合、`src/config.ps1` の既定 NIC 名を変更してください。
   ```powershell
   $script:DefaultNicName = "ネットワーク アダプター"
   ```

## 使い方

PowerShell を**管理者権限**で開き、リポジトリのルートディレクトリで実行してください。

```powershell
# 実行ポリシーを一時的に緩和（必要に応じて）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# 前提条件の確認
.\Check_Requireenvironment.ps1

# ラボ構成の作成
.\Build_labo.ps1

# ラボ構成の削除
.\Delete_labo.ps1
```

> **注意**: `Check_Requireenvironment.ps1`、`Build_labo.ps1`、`Delete_labo.ps1` では、実行ポリシーが `Restricted` または `AllSigned` の場合、現在のプロセスのみ `RemoteSigned` に自動的に緩和します。恒久的に変更する場合は、管理者権限で `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine` を実行してください。

## 個別スクリプト

| スクリプト | 用途 |
|---|---|
| `Check_Requireenvironment.ps1` | Hyper-V 有効化、外部スイッチ有無、物理アダプター Up 状態を確認 |
| `Build_labo.ps1` | スイッチ → VyOS → Linux → Windows Server の順に作成・起動 |
| `Delete_labo.ps1` | VM → VHD → スイッチ の順に削除 |
| `src/Connect_DefaultSwitch.ps1` | 全 VM を Default Switch に接続し、外部通信を可能にする |
| `src/Remove_vyosdvd.ps1` | VyOS VM から ISO をアンマウント |
| `src/Generate-VyOSSeedIso.ps1` | VyOS 用 cloud-init seed.iso を生成 |
| `src/Deploy_WindowsServer.ps1` | Windows Server VM を作成・起動 |
| `src/Configure-AD.ps1` | PowerShell Direct で AD サイト間構成を自動化 |
| `src/Start_windows.ps1` | 全 Windows Server VM を起動 |
| `src/Stop_windows.ps1` | 全 Windows Server VM を停止 |
| `src/Remove_windows.ps1` | 全 Windows Server VM を削除 |
| `src/Remove_windowsvhdx.ps1` | 全 Windows Server VM の VHD を削除 |

## VyOS ネットワーク設定の自動化

VyOS 1.3 / 1.4 系は cloud-init に対応しています。`src/cloud-init/vyos/` にある `user-data` / `meta-data` を編集し、
`src/Generate-VyOSSeedIso.ps1` を実行すると `C:\ISO\vyos-seed.iso` が生成されます。

`Build_labo.ps1` 実行時、`Deploy_VyOS.ps1` が自動的に seed.iso を生成し、VyOS VM の 2 台目 DVD ドライブにマウントします。
これにより、VyOS 初回起動時に以下の設定が自動化されます。

- ユーザー `vyos` / パスワード `vyos` の作成
- SSH サービスの有効化
- 各 NIC の DHCP 設定

`user-data` の `vyos_config_commands` を編集することで、静的 IP や OSPF/BGP 等のルーティング設定も自動化できます。

### サンプル: 静的 IP + OSPF

```yaml
vyos_config_commands:
  - set system host-name 'vyos-labo'
  - set service ssh port '22'
  - set interfaces ethernet eth0 address '192.168.10.1/24'
  - set interfaces ethernet eth1 address '10.0.0.1/24'
  - set protocols ospf area 0 network '192.168.10.0/24'
  - set protocols ospf area 0 network '10.0.0.0/24'
```

> **注意**: cloud-init の動作は VyOS のバージョンやビルドによって異なる場合があります。動作しない場合は、Hyper-V コンソールから手動で設定してください。

## Active Directory サイト間構成の自動化

Windows Server VM の OS インストールが完了したら、Hyper-V ホスト側から `src/Configure-AD.ps1` を実行することで、
PowerShell Direct を使用して VM 内に AD 設定を流し込むことができます。

### 実行内容

1. **SiteA-ADC** にフォレスト `labo.local` を構築
2. **SiteB-ADC** / **DMZ-ADC** を追加 DC としてプロモート
3. サイト **SiteA** / **SiteB** / **DMZ** と、それぞれのサブネットを紐付け
4. サイト間リンクを作成（SiteA ↔ SiteB、SiteA ↔ DMZ）

### 実行手順

```powershell
# Windows Server VM の OS インストールが完了してから実行
.\src\Configure-AD.ps1
```

### テンプレートファイル

- `src/templates/ad/Install-ADDSForest.ps1`: フォレスト構築
- `src/templates/ad/Install-ADDSDomainController.ps1`: 追加 DC プロモート
- `src/templates/ad/Configure-ADSites.ps1`: サイト/サブネット/サイトリンク構成

これらのテンプレートを編集することで、ドメイン名やサイト名、サブネットをカスタマイズできます。

> **注意**: PowerShell Direct を使用するため、VM 内の OS インストールが完了し、PowerShell リモート処理が有効になっている必要があります。Windows Server では通常デフォルトで有効です。

## 注意事項

- 本ツールは検証用です。本番環境や重要なデータが入っている端末での実行は注意してください。
- OS インストール後は、各 VM から ISO をアンマウントすることを推奨します（`src/Remove_vyosdvd.ps1` 等）。
- 外部スイッチ作成時に、物理アダプターを選択するプロンプトが表示されます。
- Generation 2 VM を使用するため、一部の古い ISO ではブートしない場合があります。必要に応じて `src/config.ps1` の `$script:VmGeneration` を `1` に変更してください。

## 今後の予定

- Vagrant や Ansible、Kickstart / cloud-init を利用して、上物のサンプルコンフィグ（k8s 構成等）の自動化に挑戦

## 動作確認環境

- ThinkPad T480 / Memory 32 GiB（旧版にて確認）
- Windows 11 Pro / PowerShell 7.x / Windows PowerShell 5.1

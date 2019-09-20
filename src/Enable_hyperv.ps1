try{
    $Status = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -ErrorAction Stop -ErrorVariable "err"

    if($Status.State -ne "enabled"){
        Write-Host "Hyper-Vは有効化されていません。その他仮想化ソフトを利用している場合は不具合が発生する場合はあります。有効化しますか？(y/n):"
        $input = Read-Host
        if($input -eq "y"){
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
            break;
        }else{
            break;
        }
    }else{
        Write-host "hyperstatus:ok" -ForegroundColor Blue
    }

}catch {
    Write-Host "エラー: $err" -ForegroundColor Red
}


Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Stop_centos.ps1" `
    -NoNewWindow `
    -Wait 
    
    
Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Stop_vyos.ps1" `
    -NoNewWindow `
    -Wait


Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_centos.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_vyos.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_vyosvhdx.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_centosvhdx.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_Switch.ps1" `
    -NoNewWindow `
    -Wait

    

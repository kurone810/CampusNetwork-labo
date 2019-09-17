Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Deploy_Switch.ps1" `
    -NoNewWindow `
    -Wait 
    
    
Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Deploy_VyOS.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Deploy_CentOS.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Start_vyos.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Start_centos.ps1" `
    -NoNewWindow `
    -Wait



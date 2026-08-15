Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Deploy_Switch.ps1" `
    -NoNewWindow `
    -Wait 
    
    
Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Deploy_NetworkOS.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Deploy_Server.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Start_NetworkOS.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Start_Server.ps1" `
    -NoNewWindow `
    -Wait

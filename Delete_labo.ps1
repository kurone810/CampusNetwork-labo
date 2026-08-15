Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Stop_Server.ps1" `
    -NoNewWindow `
    -Wait 
    
    
Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Stop_NetworkOS.ps1" `
    -NoNewWindow `
    -Wait


Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_Server.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_NetworkOS.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_NetworkOSvhdx.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_Servervhdx.ps1" `
    -NoNewWindow `
    -Wait

Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Remove_Switch.ps1" `
    -NoNewWindow `
    -Wait

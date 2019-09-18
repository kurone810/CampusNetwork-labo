Start-Process `
    -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-Command .\src\Enable_hyperv.ps1 -Verb runas" `
    -NoNewWindow `
    -Wait 

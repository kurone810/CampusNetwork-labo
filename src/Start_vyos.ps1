﻿Get-VM | Where-Object {$_.Name -like "*vyos*-labo" -and $_.Name -ne "vyOS_template"}| Start-VM
Get-VM
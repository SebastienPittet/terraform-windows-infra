# Configure next step (run_02) before reboot
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/SebastienPittet/terraform-windows-infra/master/powershell-scripts/run_02.ps1" `
  -OutFile "C:\Program Files\EXOSCALE\run_02.ps1"

New-ItemProperty `
  -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
  -Name "Run-02" `
  -Value "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -File ""C:\Program Files\EXOSCALE\run_02.ps1"" " `
  -PropertyType "String"


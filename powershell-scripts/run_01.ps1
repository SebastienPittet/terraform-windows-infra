$my_secure_password = convertto-securestring "Exoscal3!" -asplaintext -force

Set-LocalUser `
 -Name Administrator `
 -AccountNeverExpires `
 -Password $my_secure_password `
 -PasswordNeverExpires $true

Install-windowsfeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath “C:\Windows\NTDS” `
-DomainMode “Win2012R2” `
-DomainName “yourdomain.internal” `
-DomainNetbiosName “YOURDOMAIN” `
-ForestMode “Win2012R2” `
-InstallDns:$true `
-LogPath “C:\Windows\NTDS” `
-NoRebootOnCompletion:$true `
-SysvolPath “C:\Windows\SYSVOL” `
-Force:$true `
-SafeModeAdministratorPassword $my_secure_password

New-ADComputer `
 -Name "FS01" `
 -AccountPassword $my_secure_password

# Configure next step (run_02) before reboot
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/SebastienPittet/lametric-ssl-expiry/master/requirements.txt" `
  -OutFile "C:\Program Files\EXOSCALE\run_02.ps1"

New-ItemProperty `
  -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
  -Name "Step2" `
  -Value "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe ""C:\Program Files\EXOSCALE\run_02.ps1"" " `
  -PropertyType "String"

Restart-Computer
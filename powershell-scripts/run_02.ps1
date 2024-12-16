New-ADComputer `
 -Name "FS01" `
 -AccountPassword $my_secure_password

 #next steps !
 #...

New-ItemProperty `
  -Path "HKLM:\Software\${var.addsNETBIOS}" `
  -Name "Step 2" `
  -Value "run_02.ps1=Done!" `
  -PropertyType "String"
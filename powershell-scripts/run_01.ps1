# Configure next step (run_02) before reboot
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/SebastienPittet/terraform-windows-infra/master/powershell-scripts/run_02.ps1" `
  -OutFile "C:\Program Files\EXOSCALE\run_02.ps1"

New-ItemProperty `
  -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
  -Name "Run-02" `
  -Value "powershell.exe -File ""C:\Program Files\EXOSCALE\run_02.ps1"" " `
  -PropertyType "String"

  $privIntAlias = (Get-NetIPAddress -IPAddress "10.0.0.20" | Select-Object -Property InterfaceAlias).InterfaceAlias
  Set-DnsClientServerAddress -InterfaceAlias $privIntAlias -ServerAddresses 1.1.1.1
  
  
  Install-WindowsFeature DHCP `
    -IncludeManagementTools
  Restart-Service dhcpserver
  Add-DhcpServerInDC -DnsName DC01.exoscale.internal -IPAddress 10.0.0.20
  Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
  Add-DhcpServerv4Scope -name "Exoscale" -StartRange 10.0.0.100 -EndRange 10.0.0.150 -SubnetMask 255.255.255.0 -State Active
  Add-DhcpServerv4ExclusionRange -ScopeID 10.0.0.0 -StartRange 10.0.0.1 -EndRange 10.0.0.100
  Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.1 -ScopeID 10.0.0.0 -ComputerName DC01.exoscale.internal
  Set-DhcpServerv4OptionValue -DnsDomain exoscale.internal -DnsServer 10.0.0.20
  
New-ItemProperty `
  -Path "HKLM:\Software\${var.addsNETBIOS}" `
  -Name "Step 1" `
  -Value "run_01.ps1=Done!" `
  -PropertyType "String"

  Restart-Computer `
    -Force

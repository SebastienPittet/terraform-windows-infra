data "exoscale_compute_template" "active-directory" {
  zone = local.zone
  name = "Windows Server 2022"
}

resource "exoscale_anti_affinity_group" "ADservers" {
  name        = "Active Directory Servers"
  description = "Domain controllers"
}

resource "exoscale_compute_instance" "dc01" {
  zone               = local.zone
  name               = "DC01"
  type               = "standard.large"
  template_id        = data.exoscale_compute_template.active-directory.id
  disk_size          = 60
  security_group_ids = [exoscale_security_group.rdpservers.id]
  network_interface {
    network_id = exoscale_private_network.lan-managed.id
    ip_address = "10.0.0.20"
  }
  
  anti_affinity_group_ids = [exoscale_anti_affinity_group.ADservers.id]

  user_data          = <<EOF
#ps1
$my_secure_password = convertto-securestring "Exoscal3!" -asplaintext -force

Set-LocalUser `
 -Name Administrator `
 -AccountNeverExpires `
 -Password $my_secure_password `
 -PasswordNeverExpires $true

New-Item `
  -ItemType "directory" `
  -Path "c:\Program Files" `
  -Name "EXOSCALE" `
  -Force

New-Item `
  -Path "HKLM:\SOFTWARE" `
  -Name "EXOSCALE" `
  -Force


Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/SebastienPittet/terraform-windows-infra/master/powershell-scripts/run_01.ps1" `
  -OutFile "C:\Program Files\EXOSCALE\run_01.ps1"


New-ItemProperty `
  -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
  -Name "Run01" `
  -Value "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -File ""C:\Program Files\EXOSCALE\run_01.ps1"" " `
  -PropertyType "String"


Install-windowsfeature AD-Domain-Services -IncludeManagementTools


Install-ADDSForest `
 -CreateDnsDelegation:$false `
 -DatabasePath "C:\Windows\NTDS" `
 -DomainMode "Win2012R2" `
 -DomainName "exoscale.local" `
 -DomainNetbiosName "EXOSCALE" `
 -ForestMode "Win2012R2" `
 -InstallDns:$true `
 -LogPath "C:\Windows\NTDS" `
 -NoRebootOnCompletion:$false `
 -SysvolPath "C:\Windows\SYSVOL" `
 -Force:$true `
 -SafeModeAdministratorPassword $my_secure_password

New-ItemProperty `
  -Path "HKLM:\Software\EXOSCALE" `
  -Name "TF-Executed" `
  -Value "<3 cloud-init user data!" `
  -PropertyType "String"

EOF
}

output "ADdnsServer" {
  value = exoscale_compute_instance.dc01.public_ip_address
  description = "The IP of internal DNS server"
}

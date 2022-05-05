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

New-ItemProperty `
  -Path "HKLM:\Software\EXOSCALE" `
  -Name "TF-Executed" `
  -Value "<3 cloud-init user data!" `
  -PropertyType "String"

Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/SebastienPittet/lametric-ssl-expiry/master/requirements.txt" `
  -OutFile "C:\Program Files\EXOSCALE\requirements.txt"

New-ItemProperty `
  -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
  -Name "Step2" `
  -Value "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe ""C:\Program Files\EXOSCALE\test.ps1"" " `
  -PropertyType "String"

Restart-Computer
EOF
}

output "ADdnsServer" {
  value = exoscale_compute_instance.dc01.public_ip_address
  description = "The IP of internal DNS server"
}

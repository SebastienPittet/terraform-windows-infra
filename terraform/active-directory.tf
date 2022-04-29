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

install-windowsfeature AD-Domain-Services -IncludeManagementTools


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

New-ADUser `
 -Name "Exoscale" `
 -SamAccountName "Exoscale" `
 -CannotChangePassword $true `
 -ChangePasswordAtLogon $false `
 -PasswordNeverExpires $true `
 -Company "Exoscale" `
 -DisplayName "Exoscale" `
 -Accountpassword (ConvertTo-SecureString -String 'Exoscal3!' -AsPlainText -Force)[0] `
 -Enabled $true

Restart-Computer

Add-ADGroupMember `
 -Identity Administrators `
 -Members Exoscale

EOF
}

output "ADdnsServer" {
  value = exoscale_compute_instance.dc01.public_ip_address
  description = "The IP of internal DNS server"
}
data "exoscale_compute_template" "file-service" {
  zone = local.zone
  name = "Windows Server 2022"
}

resource "exoscale_anti_affinity_group" "FILEservers" {
  name        = "File Servers (DFS)"
  description = "Windows File servers using DFS-R"
}

resource "exoscale_compute_instance" "fs01" {
  zone               = local.zone
  name               = "FS01"
  type               = "standard.large"
  template_id        = data.exoscale_compute_template.file-service.id
  disk_size          = 60
  security_group_ids = [exoscale_security_group.rdpservers.id]
  network_interface {
    network_id = exoscale_private_network.lan-managed.id
    ip_address = "10.0.0.30"
  }
  
  anti_affinity_group_ids = [exoscale_anti_affinity_group.FILEservers.id]

  user_data          = <<EOF
#ps1

Set-DnsClientServerAddress `
 -Serveraddresses 


Install-WindowsFeature FS-BranchCache FS-Data-Deduplication -IncludeManagementTools

$my_secure_password = convertto-securestring "Exoscal3!" -asplaintext -force

Set-LocalUser `
 -Name Administrator `
 -AccountNeverExpires `
 -Password $my_secure_password `
 -PasswordNeverExpires $true

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $null
    Password = $my_secure_password
})


Start-Sleep -s 600

Add-Computer `
 -DomainName "YOURDOMAIN" `
 -ComputerName "FS01" `
 -Options UnsecuredJoin,PasswordPass `
 -Credential $joinCred
 -Server YOURDOMAIN\DC01
EOF
}

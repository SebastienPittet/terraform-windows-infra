data "exoscale_compute_template" "file-service" {
  zone = local.zone
  name = "Windows Server 2022"
}

resource "exoscale_anti_affinity_group" "FILEservers" {
  name        = "File Servers (DFS)"
  description = "Windows File servers using DFS-R"
}

# This resource will create (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait_3_minutes" {
  depends_on = [null_resource.previous]

  create_duration = "3m"
}
 
resource "exoscale_compute_instance" "fs01" {
  depends_on = [time_sleep.wait_3_minutes]
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

$privIntAlias = (Get-NetIPAddress -IPAddress "10.0.0.30" | Select-Object -Property InterfaceAlias).InterfaceAlias
Set-DnsClientServerAddress -InterfaceAlias $privIntAlias -ServerAddresses 10.0.0.20

Install-WindowsFeature `
  File-Services, `
  FS-FileServer, `
  FS-BranchCache, `
  FS-Data-Deduplication, `
  FS-DFS-Namespace, `
  FS-DFS-Replication, `
  FS-VSS-Agent `
 -IncludeManagementTools

#Get-NetAdapter | Where-Object {$_.Name -eq "Ethernet"} | Set-DnsClientServerAddress `
# -ServerAddresses ${exoscale_compute_instance.dc01.public_ip_address}

$my_secure_password = convertto-securestring "${var.default_password}" -asplaintext -force
$username = "Administrator"

$credObject = New-Object System.Management.Automation.PSCredential ($userName, $my_secure_password)

Set-LocalUser `
 -Name $username `
 -AccountNeverExpires `
 -Password $my_secure_password `
 -PasswordNeverExpires $true

Add-Computer `
 -ComputerName FS01 `
 -LocalCredential $credObject `
 -DomainName exoscale.internal `
 -Credential $credObject `
 # -Options UnsecuredJoin,PasswordPass `
 -Restart

EOF
}

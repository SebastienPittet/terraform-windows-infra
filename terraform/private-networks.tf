resource "exoscale_private_network" "lan-managed" {
  zone        = local.zone
  name        = "LAN-1"
  description = "Local Area Network with DHCP"
  start_ip    = "10.0.0.20"
  end_ip      = "10.0.0.253"
  netmask     = "255.255.255.0"
}
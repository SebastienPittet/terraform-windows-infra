data "exoscale_compute_template" "fw" {
  zone = local.zone
  name = "FortiGate 7.0 BYOL"
}

resource "exoscale_compute_instance" "firewall" {
  zone               = local.zone
  name               = "Firewall"
  type               = "standard.small"
  template_id        = data.exoscale_compute_template.fw.id
  disk_size          = 50
  security_group_ids = [exoscale_security_group.vpn.id]
  network_interface {
    network_id = exoscale_private_network.lan-managed.id
    ip_address = "10.0.0.1"
  }
}

resource "exoscale_security_group" "rdpservers" {
  name             = "RDP"
  description      = "Remote Desktop Protocol"
  external_sources = ["0.0.0.0/0"]
}


resource "exoscale_security_group_rule" "rdprule" {
  security_group_id = exoscale_security_group.rdpservers.id
  description = "Allow TCP 3389"
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0" # "::/0" for IPv6
  start_port        = 3389
  end_port          = 3389
}

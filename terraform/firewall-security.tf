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


resource "exoscale_security_group" "vpn" {
  name             = "VPN"
  description      = "Virtual Private Network"
  external_sources = ["0.0.0.0/0"]
}


resource "exoscale_security_group_rule" "security-rules-esp" {
  security_group_id = exoscale_security_group.vpn.id
  type = "INGRESS"
  protocol = "ESP"
  cidr = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "security-rules-udp500" {
  security_group_id = exoscale_security_group.vpn.id
  type = "INGRESS"
  protocol = "UDP"
  cidr = "0.0.0.0/0"
  start_port = "500"
  end_port = "500"
}

resource "exoscale_security_group_rule" "security-rules-udp4500" {
  security_group_id = exoscale_security_group.vpn.id
  type = "INGRESS"
  protocol = "UDP"
  cidr = "0.0.0.0/0"
  start_port = "4500"
  end_port = "4500"
}

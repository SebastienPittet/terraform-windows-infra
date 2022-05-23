variable "default_password" {
  type    = string
  default = "Ex0scal3!"
  sensitive = true
}

variable "addsName" {
  type    = string
  default = "Exoscale.Internal"
  sensitive = false
}

variable "addsNETBIOS" {
  type = string
  default = "EXOSCALE"
  sensitive = false
}

locals {
  zone = "ch-gva-2"
}
terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.35"
    }
  }
}

provider "exoscale" {
  config = "cloudstack.ini"
  region = "demo-exoscale"

  timeout = 240          # default: waits 60 seconds in total for a resource
}
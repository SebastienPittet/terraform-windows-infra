output "connect-dc01" {
  sensitive = false
  value = "mstsc.exe /admin /v:${exoscale_compute_instance.dc01.public_ip_address}:3389 /fullscreen"
}

output "connect-fs01" {
  sensitive = false
  value = "mstsc.exe /admin /v:${exoscale_compute_instance.fs01.public_ip_address}:3389 /fullscreen"
}

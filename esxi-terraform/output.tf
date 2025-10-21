output "vm_ips" {
  value = {
    web1 = esxi_guest.web1.ip_address
    web2 = esxi_guest.web2.ip_address
    db   = esxi_guest.db.ip_address
  }
}

resource "local_file" "vm_ips" {
  content  = join("\n", [
    "web1: ${esxi_guest.web1.ip_address}",
    "web2: ${esxi_guest.web2.ip_address}",
    "db: ${esxi_guest.db.ip_address}"
  ])
  filename = "${path.module}/vm_ips.txt"
}

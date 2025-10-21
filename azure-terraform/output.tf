resource "local_file" "vm_ips" {
  content  = join("\n", [for vm_name, vm in azurerm_linux_virtual_machine.ubuntu_vm : "${vm_name}: ${vm.public_ip_address}"])
  filename = "${path.module}/vm_ips.txt"
}
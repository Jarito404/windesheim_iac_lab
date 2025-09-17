variable "esxi_host" {
  description = "ESXi host IP"
  type        = string
  default     = "192.168.1.10"
}

variable "esxi_user" {
  description = "ESXi user"
  type        = string
  default     = "root"
}

variable "esxi_password" {
  description = "ESXi password"
  type        = string
  default     = "Welkom01!"
}

variable "datastore" {
  description = "Datastore name"
  type        = string
  default     = "datastore1"
}

variable "network" {
  description = "Virtual network"
  type        = string
  default     = "VM Network"
}

variable "base_vm_name" {
  description = "Naam van de bestaande powered-off Ubuntu cloud-image VM"
  type        = string
  default     = "ubuntu-base-vm"
}

variable "ssh_pub_key_path" {
  description = "Pad naar public ssh key (ED25519)"
  type        = string
  default     = "${path.module}/id_ed25519.pub"
}

variable "vm_memory_mb" {
  description = "Geheugen per VM in MB"
  type        = number
  default     = 2048
}

variable "vm_vcpu" {
  description = "Aantal vCPU's per VM"
  type        = number
  default     = 1
}

variable "output_ip_file" {
  description = "Pad waar de IP-adressen op het beheer-systeem worden weggeschreven"
  type        = string
  default     = "./vm_ips.txt"
}

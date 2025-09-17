variable "resource_group_name" {
  description = "Naam van bestaande Azure resource group"
  type        = string
  default     = "iac_lab_s1204935"
}

variable "location" {
  description = "Azure locatie"
  type        = string
  default     = "westeurope"
}

variable "vm_size" {
  description = "Type VM"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin user op de VM"
  type        = string
  default     = "iac"
}

variable "ssh_pub_key_path" {
  description = "Pad naar SSH public key"
  type        = string
  default     = "${path.module}/id_ed25519.pub"
}

variable "output_ip_file" {
  description = "Bestand waarin de publieke IP-adressen worden weggeschreven"
  type        = string
  default     = "./azure_vm_ips.txt"
}

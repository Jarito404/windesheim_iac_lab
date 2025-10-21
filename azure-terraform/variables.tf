variable "resource_group_name" {
  default     = "iac_lab_s1204935"
}

variable "location" {
  default     = "westeurope"
}

variable "vm_size" {
  default     = "Standard_B2ts_v2"
}

variable "admin_username" {
  default     = "iac"
}

variable "ssh_pub_key_path" {
  default     = "/id_rsa.pub"
}

variable "esxi_hostname" {
  default = "192.168.1.10"
}

variable "esxi_hostport" {
  default = "22"
}

variable "esxi_hostssl" {
  default = "443"
}

variable "esxi_username" {
  default = "root"
}

variable "esxi_password" {
  default = "Welkom01!"
}

variable "ssh_pub_key_path" {
  default     = "/id_ed25519.pub"
}

variable "output_ip_file" {
  default     = "./vm_ips.txt"
}

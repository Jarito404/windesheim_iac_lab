terraform {
  required_version = ">= 1.3.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.6"
    }
  }
}

provider "esxi" {
  esxi_hostname = "192.168.1.10"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = "Welkom01!"
}

#
resource "esxi_guest" "vm01" {
  guest_name = "vm1"
  disk_store = "datastore1"
  network_interfaces {
    virtual_network = "VM Network"
  }
}

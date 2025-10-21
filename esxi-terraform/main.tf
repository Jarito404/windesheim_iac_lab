terraform {
  required_version = ">= 1.3.0"
  required_providers {
    esxi = {
      source  = "registry.terraform.io/josenk/esxi"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "esxi_guest" "web1" {
  guest_name = "webserver01"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "6"

  memsize            = "2048"
  numvcpus           = "1"
  # resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "base-ubuntu"


  network_interfaces {
    virtual_network = "VM Network"
    nic_type        = "e1000"
  }
  network_interfaces {
    virtual_network = "VM Network"
  }

  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}

resource "esxi_guest" "web2" {
  guest_name = "webserver02"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "6"

  memsize            = "2048"
  numvcpus           = "1"
  # resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "base-ubuntu"


  network_interfaces {
    virtual_network = "VM Network"
    nic_type        = "e1000"
  }
  network_interfaces {
    virtual_network = "VM Network"
  }

  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}

resource "esxi_guest" "db" {
  guest_name = "databaseserver"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "6"

  memsize            = "2048"
  numvcpus           = "1"
  # resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "base-ubuntu"


  network_interfaces {
    virtual_network = "VM Network"
    nic_type        = "e1000"
  }
  network_interfaces {
    virtual_network = "VM Network"
  }

  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}

# lees ED25519 public key
locals {
  pubkey_raw = trimspace(file(var.ssh_pub_key_path))
  cloudinit  = replace(file("${path.module}/cloudinit.yml"), "PLACEHOLDER_PUBKEY", local.pubkey_raw)
}

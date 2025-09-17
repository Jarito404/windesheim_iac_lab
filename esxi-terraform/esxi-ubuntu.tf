terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.6"
    }
  }
}

provider "vsphere" {
  user                 = "root@192.168.1.10"
  password             = "Welkom01!"
  vsphere_server       = "192.168.1.10"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "ubuntu_base" {
  name          = "ubuntu-base-vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "ubuntu_clone" {
  name             = "ubuntu-clone"
  resource_pool_id = "ha-root-pool"
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.ubuntu_base.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.ubuntu_base.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.ubuntu_base.disks[0].size
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu_base.id
  }
}

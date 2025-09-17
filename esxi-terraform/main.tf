terraform {
  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "~> 1.8"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

provider "esxi" {
  host     = var.esxi_host
  username = var.esxi_user
  password = var.esxi_password
  # allow_insecure_tls = true   # uncomment only if je ESXi self-signed certs gebruikt en je wilt overslaan
}

# bij standalone ESXi is datacenter altijd "ha-datacenter"
data "esxi_datacenter" "dc" {
  name = "ha-datacenter"
}

data "esxi_datastore" "ds" {
  name = var.datastore
  datacenter = data.esxi_datacenter.dc.name
}

data "esxi_network" "net" {
  name = var.network
  datacenter = data.esxi_datacenter.dc.name
}

# basis (bestaande) powered-off VM die je eerder hebt gemaakt met Ubuntu 24.04 cloud image
data "esxi_guest" "base" {
  guest_name = var.base_vm_name
  datastore  = data.esxi_datastore.ds.name
}

# lees ED25519 public key
locals {
  pubkey_raw = trimspace(file(var.ssh_pub_key_path))
  cloudinit  = replace(file("${path.module}/cloudinit.yml"), "PLACEHOLDER_PUBKEY", local.pubkey_raw)
}

# 2 webservers (count)
resource "esxi_guest" "webserver" {
  count           = 2
  guest_name      = "webserver-${count.index + 1}"
  datastore       = data.esxi_datastore.ds.name
  disk_store      = data.esxi_datastore.ds.name
  boot_disk_size  = tostring(20)          # GB
  memsize         = tostring(var.vm_memory_mb)
  numvcpus        = tostring(var.vm_vcpu)
  power           = "on"
  guestos         = "ubuntu-64"
  network_interfaces {
    virtual_network = data.esxi_network.net.name
  }

  source_image = data.esxi_guest.base.guest_name
  # cloud-init userdata via provider userdata field (provider supports userdata per example/docs)
  userdata = base64encode(local.cloudinit)

  # wacht tot guest gereed is? (afhankelijk van provider mogelijke attributes)
  # gebruik "extra_config" of andere settings indien nodig per provider versie
}

# 1 databaseserver
resource "esxi_guest" "dbserver" {
  guest_name      = "databaseserver-1"
  datastore       = data.esxi_datastore.ds.name
  disk_store      = data.esxi_datastore.ds.name
  boot_disk_size  = tostring(20)
  memsize         = tostring(var.vm_memory_mb)
  numvcpus        = tostring(var.vm_vcpu)
  power           = "on"
  guestos         = "ubuntu-64"
  network_interfaces {
    virtual_network = data.esxi_network.net.name
  }

  source_image = data.esxi_guest.base.guest_name
  userdata     = base64encode(local.cloudinit)
}

# Verzamel IPs (LET OP: attribute name kan per provider versie verschillen — zie toelichting onderaan)
# Ik probeer hier het veelgebruikte attribuut `ip_address` en `default_ip` te lezen en concatenen in een lijst.
locals {
  all_ips = concat(
    [for s in esxi_guest.webserver : try(s.ip_address, try(s.default_ip, ""))],
    [try(esxi_guest.dbserver.ip_address, try(esxi_guest.dbserver.default_ip, ""))]
  )
  all_ips_clean = [for ip in local.all_ips : ip if ip != ""]
  ips_text = join("\n", local.all_ips_clean)
}

# Schrijf IPs weg naar een local file op jouw beheer-systeem
resource "local_file" "ips_file" {
  content  = local.ips_text
  filename = var.output_ip_file
}

output "vm_names" {
  value = concat([for s in esxi_guest.webserver : s.guest_name], [esxi_guest.dbserver.guest_name])
}

output "vm_ips" {
  value = local.all_ips_clean
}

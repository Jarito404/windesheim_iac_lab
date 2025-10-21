terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ubuntu-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "ubuntu-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# lokale lijst van vm namen
locals {
  vm_names = ["web1", "web2"]
}

# public IPs per vm
resource "azurerm_public_ip" "pip" {
  for_each            = toset(local.vm_names)
  name                = "${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku = "Standard"
}

# NIC
resource "azurerm_network_interface" "nic" {
  for_each            = toset(local.vm_names)
  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

# De Ubuntu VMs
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  for_each            = toset(local.vm_names)
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_pub_key_path)
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Cloud-init
  custom_data = base64encode(file("${path.module}/cloud-init/user-data.yaml"))
}

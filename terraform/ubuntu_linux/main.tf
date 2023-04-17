terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.51.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "secOps" {
  name     = "secOps-tf-rg"
  location = "eastus"
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_virtual_network" "secOps-vnet" {
  name                = "secOps-tf-vnet"
  resource_group_name = azurerm_resource_group.secOps.name
  location            = azurerm_resource_group.secOps.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_subnet" "secOps-subnet" {
  name                 = "secOps-tf-subnet"
  resource_group_name  = azurerm_resource_group.secOps.name
  virtual_network_name = azurerm_virtual_network.secOps-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "secOps-nsg" {
  name                = "secOps-tf-nsg"
  location            = azurerm_resource_group.secOps.location
  resource_group_name = azurerm_resource_group.secOps.name
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_security_rule" "secOps-dev-ssh-rule" {
  name                        = "secOps-tf-dev-ssh-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${chomp(data.http.my-home-ip.response_body)}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.secOps.name
  network_security_group_name = azurerm_network_security_group.secOps-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "secOps-subnet-nsg" {
  subnet_id                 = azurerm_subnet.secOps-subnet.id
  network_security_group_id = azurerm_network_security_group.secOps-nsg.id
}

resource "random_uuid" "get-uuid" {}

resource "azurerm_public_ip" "secOps-ip" {
  name                = "secOps-tf-ip-${random_uuid.get-uuid.result}"
  location            = azurerm_resource_group.secOps.location
  resource_group_name = azurerm_resource_group.secOps.name
  allocation_method   = "Dynamic"
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_interface" "secOps-nic" {
  name                = "secOps-tf-nic"
  location            = azurerm_resource_group.secOps.location
  resource_group_name = azurerm_resource_group.secOps.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.secOps-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.secOps-ip.id
  }
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_linux_virtual_machine" "secOps-linux-vm-01" {
  name                  = "secOps-tf-linux-vm-01"
  resource_group_name   = azurerm_resource_group.secOps.name
  location              = azurerm_resource_group.secOps.location
  size                  = "Standard_D2as_v4"
  admin_username        = var.end_user
  network_interface_ids = [azurerm_network_interface.secOps-nic.id]

  custom_data = filebase64("install_devEnv.sh")

  admin_ssh_key {
    username   = var.end_user
    public_key = file("~/.ssh/secOpsAzureKey.pub")
  }

  os_disk {
    name                 = "secOps-tf-linux-vm-01-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "60"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202303290"
  }

  provisioner "local-exec" {
    command = templatefile("${local.host_os}-ssh-vscode.tpl", {
      hostname     = self.public_ip_address
      user         = var.end_user
      identityfile = "~/.ssh/secOpsAzureKey"
    })
    interpreter = local.host_os == "windows" ? ["powershell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = var.tag_env
  }
}

locals {
  os = data.external.os.result.os
  host_os = local.os == "windows" ? "windows" : "linux"
}

data "external" "os" {
  working_dir = path.module
  program = ["printf", "{\"os\": \"linux\"}"]
}

data "azurerm_public_ip" "secOps-ip-data" {
  name                = azurerm_public_ip.secOps-ip.name
  resource_group_name = azurerm_resource_group.secOps.name
}

data "http" "my-home-ip" {
  url = "http://ipv4.icanhazip.com"
}

output "local_host_os" {
  value = "${local.host_os}" 
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.secOps-linux-vm-01.name}: ${data.azurerm_public_ip.secOps-ip-data.ip_address}"
}

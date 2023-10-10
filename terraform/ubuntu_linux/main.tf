terraform {

  required_providers {
     azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-devops"
    storage_account_name = "satfdevops07695"
    container_name       = "tfstate"
    key                  = "secops-00-vm-syslog.tfstate"
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }
  environment     = "public" # Cloud Types: Public, USGovernment, etc
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}


# Generate a random vm name
resource "random_string" "rstring" {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource "azurerm_resource_group" "secops" {
  depends_on = [random_string.rstring]
  name       = "secops-vm-tf-rg-${random_string.rstring.result}"
  location   = var.location
  tags = {
    environment = var.tag_env
  }
}

resource "random_uuid" "get-uuid" {}

resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.secops.name
  }
  byte_length = 8
}

data "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

resource tls_private_key main {
  algorithm  = "RSA"
  rsa_bits   = 4096
}

# Create a secret (ssh public key) in the key vault
resource azurerm_key_vault_secret ssh_public_key {
  depends_on   = [tls_private_key.main, data.azurerm_key_vault.main]
  key_vault_id = data.azurerm_key_vault.main.id
  name         = "${local.hostname}-ssh-public-key"
  value        = tls_private_key.main.public_key_openssh
}

# Create a secret (ssh private key) in the key vault
resource azurerm_key_vault_secret ssh_private_key {
  depends_on   = [tls_private_key.main, data.azurerm_key_vault.main]
  key_vault_id = data.azurerm_key_vault.main.id
  name         = "${local.hostname}-ssh-private-key"
  value        = tls_private_key.main.private_key_pem
}


resource "azurerm_virtual_network" "secops-vnet" {
  name                = "secops-tf-vnet-${random_id.random_id.hex}"
  resource_group_name = azurerm_resource_group.secops.name
  location            = azurerm_resource_group.secops.location
  address_space       = [var.network_vnet_cidr]
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_subnet" "secops-subnet" {
  name                 = "secops-tf-subnet-${random_id.random_id.hex}"
  resource_group_name  = azurerm_resource_group.secops.name
  virtual_network_name = azurerm_virtual_network.secops-vnet.name
  address_prefixes     = [var.vm_subnet_cidr]
}

resource "azurerm_network_security_group" "secops-nsg" {
  name                = "secops-tf-nsg-${random_id.random_id.hex}"
  location            = azurerm_resource_group.secops.location
  resource_group_name = azurerm_resource_group.secops.name
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_security_rule" "secops-dev-ssh-rule" {
  name                        = "secops-tf-dev-ssh-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${chomp(data.http.my-home-ip.response_body)}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.secops.name
  network_security_group_name = azurerm_network_security_group.secops-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "secops-subnet-nsg" {
  subnet_id                 = azurerm_subnet.secops-subnet.id
  network_security_group_id = azurerm_network_security_group.secops-nsg.id
}

resource "azurerm_public_ip" "secops_ip" {
  name                = "secops-tf-ip-${random_id.random_id.hex}"
  location            = azurerm_resource_group.secops.location
  resource_group_name = azurerm_resource_group.secops.name
  allocation_method   = "Dynamic"
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_interface" "secops-nic" {
  name                = "secops-tf-nic-${random_id.random_id.hex}"
  location            = azurerm_resource_group.secops.location
  resource_group_name = azurerm_resource_group.secops.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.secops-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.secops_ip.id
  }
  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_linux_virtual_machine" "secops-linux-vm" {
  depends_on            = [
    azurerm_network_interface.secops-nic,
    azurerm_key_vault_secret.ssh_public_key,
    azurerm_key_vault_secret.ssh_private_key
  ]
  name                  = local.hostname
  resource_group_name   = azurerm_resource_group.secops.name
  location              = azurerm_resource_group.secops.location
  size                  = "Standard_D2as_v4"
  admin_username        = var.vm_username
  network_interface_ids = [azurerm_network_interface.secops-nic.id]

  custom_data = base64encode(templatefile("${path.module}/init_script.tpl", { VM_USERNAME = "${var.vm_username}" }))

  admin_ssh_key {
    username   = var.vm_username
    public_key = azurerm_key_vault_secret.ssh_public_key.value
  }

  os_disk {
    name                 = "secops-vm-tf-osdisk-${random_id.random_id.hex}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "80"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${local.host_os}_ssh_vscode.tpl", {
      hostname     = self.public_ip_address
      user         = var.vm_username
      username     = data.external.host_username.result.username
      identityfile = pathexpand("${path.module}/ssh/${var.ssh_key_name}.pem")
    })

    interpreter = local.host_os == "windows" ? ["powershell.exe", "-command"] : ["bash", "-c"]
  }

  tags = {
    environment = var.tag_env
  }
}


locals {
  os      = data.external.os.result.os
  host_os = local.os == "windows" ? "windows" : "linux"
  hostname = "secops-vm-tf-${random_string.rstring.result}"
}


data "azurerm_public_ip" "secops_ip-data" {
  name                = azurerm_public_ip.secops_ip.name
  resource_group_name = azurerm_resource_group.secops.name
}

data "http" "my-home-ip" {
  url = "http://ipv4.icanhazip.com"
}

data "external" "host_username" {
  program = local.os == "windows" ? ["powershell.exe", "-c", "${path.module}/get_host_user.ps1"] : ["bash", "${path.module}/get_host_user.sh"]
}

data "external" "os" {
  working_dir = path.module
  program     = ["printf", "{\"os\": \"linux\"}"]
}

resource "null_resource" "create_ssh_dir" {
  depends_on = [azurerm_key_vault_secret.ssh_private_key]
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh"
    interpreter = ["bash", "-c"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

# We use the private key to connect to the Azure VM
resource "local_file" "vm-ssh-private-key" {
  depends_on = [null_resource.create_ssh_dir] 
  content    = azurerm_key_vault_secret.ssh_private_key.value
  filename   = "${path.module}/ssh/${var.ssh_key_name}.pem"
}

resource "null_resource" "set-perms-ssh_key" {
  depends_on = [
    local_file.vm-ssh-private-key,
    null_resource.create_ssh_dir
  ]
  provisioner "local-exec" {
    command = local.host_os == "linux" ? "chmod 400 ${path.module}/ssh/${var.ssh_key_name}.pem" : "icacls.exe ${path.module}\\ssh\\${var.ssh_key_name}.pem /inheritance:r"
    interpreter = local.host_os == "linux" ? ["bash", "-c"] : ["powershell.exe", "-command"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}



output "host_username" {
  value = data.external.host_username.result.username
}

output "local_host_os" {
  value = local.host_os
}

output "vm_username_bash_script" {
  value = var.vm_username
}

output "hostname_vm_tf" {
  value = azurerm_linux_virtual_machine.secops-linux-vm.name
}

output "public_ip_address" {
  value = azurerm_public_ip.secops_ip.*.ip_address
}

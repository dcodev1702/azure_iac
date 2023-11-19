######################################################################
# Boilerplate code for Terraform builds
######################################################################
# Define Terraform provider
terraform {
  required_version = "~> 1.6.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.81.0"
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
  backend azurerm {
    resource_group_name  = "rg-terraform-devops" 
    storage_account_name = "satfdev0ps1702"
    container_name       = "tfstate"
    key                  = "rhel88-vm-syslog.tfstate"
  }
}

# Configure the Azure provider
provider azurerm {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  use_msi         = true
  environment     = var.cloud_environment  # Cloud Environments: [public, usgovernment]
  client_id       = data.terraform_remote_state.key_vault.outputs.user_assigned_identity_client_id
  msi_endpoint    = var.user_assigned_identity_endpoint
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}
  
resource random_string rstring {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource random_uuid get-uuid {}

resource random_id random_id {
  keepers = {
    resource_group = azurerm_resource_group.rhel88-vm-rg.name
  }
  byte_length = 8
}

# Obtain the desired state of the provisoned Key Vault
# Requied in order to send SSH Keys to KV for storage/use.
data terraform_remote_state key_vault {
  backend = "azurerm"
  config = {
    storage_account_name = "satfdev0ps1702"
    resource_group_name  = "rg-terraform-devops"
    container_name       = "tfstate"
    key                  = "key-vault-vm-ssh-keys.tfstate"

  }
}

# Obtain the desired state of the provisioned DCR
# Required in order to associate VM to the Linux Syslog DCR
data terraform_remote_state az_tf_syslog_dcr {
  backend = "azurerm"
  config = {
    storage_account_name = "satfdev0ps1775"
    resource_group_name  = "rg-terraform-devops"
    container_name       = "tfstate"
    key                  = "dcr-syslog.tfstate"
  }
}


######################################################################
# Create a resource group (bedrock for all other resources)
######################################################################
resource azurerm_resource_group rhel88-vm-rg {
  depends_on = [random_string.rstring]
  name       = "${var.host_prefix}-rg-${random_string.rstring.result}"
  location   = var.location
  tags = {
    environment = var.tag_env
  }
}


######################################################################
# Obtain provisioned key vault; Generate & store ssh keys in key vault
######################################################################
resource tls_private_key main {
  algorithm  = "RSA"
  rsa_bits   = 4096
}

# Create a secret (ssh public key) in the key vault
resource azurerm_key_vault_secret ssh_public_key {
  depends_on   = [tls_private_key.main, data.terraform_remote_state.key_vault]
  key_vault_id = data.terraform_remote_state.key_vault.outputs.key_vault_id
  name         = "${local.hostname}-ssh-public-key"
  value        = tls_private_key.main.public_key_openssh
}

# Create a secret (ssh private key) in the key vault
resource azurerm_key_vault_secret ssh_private_key {
  depends_on   = [tls_private_key.main, data.terraform_remote_state.key_vault]
  key_vault_id = data.terraform_remote_state.key_vault.outputs.key_vault_id
  name         = "${local.hostname}-ssh-private-key"
  value        = tls_private_key.main.private_key_pem
}


####################################################################
# Create a virtual network, subnet, NSG, public IP, & NIC for the VM
####################################################################
resource azurerm_virtual_network rhel88-vm-vnet {
  name                = "${var.host_prefix}-vnet-${random_id.random_id.hex}"
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
  location            = azurerm_resource_group.rhel88-vm-rg.location
  address_space       = [var.network_vnet_cidr]
  tags = {
    environment = var.tag_env
  }
}

# Create a subnet for Network
resource azurerm_subnet rhel88-vm-subnet {
  name                 = "${var.host_prefix}-subnet"
  address_prefixes     = [var.vm_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.rhel88-vm-vnet.name
  resource_group_name  = azurerm_resource_group.rhel88-vm-rg.name
}

# Create Security Group to access linux
resource azurerm_network_security_group rhel88-vm-nsg {
  depends_on          = [azurerm_resource_group.rhel88-vm-rg]
  name                = "${var.host_prefix}-nsg-${random_id.random_id.hex}"
  location            = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
  security_rule {
    name                       = "RHEL88-Allow-RSyslog-UDP"
    description                = "Allow Remote Syslog (UDP)"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = var.syslog_udp
    source_address_prefix      = "${chomp(data.http.my-home-ip.response_body)}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RHEL88-Allow-RSyslog-TCP"
    description                = "Allow Remote Syslog (TCP)"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.syslog_tcp
    source_address_prefix      = "${chomp(data.http.my-home-ip.response_body)}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RHEL88-Allow-SSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_port
    source_address_prefix      = "${chomp(data.http.my-home-ip.response_body)}/32"
    destination_address_prefix = "*"
  }
}

# Associate the linux NSG with the subnet
resource azurerm_subnet_network_security_group_association rhel88-vm-nsg-association {
  depends_on                = [azurerm_resource_group.rhel88-vm-rg]
  subnet_id                 = azurerm_subnet.rhel88-vm-subnet.id
  network_security_group_id = azurerm_network_security_group.rhel88-vm-nsg.id
}

# Get a Static Public IP
resource azurerm_public_ip rhel88-vm-ip {
  depends_on          = [azurerm_resource_group.rhel88-vm-rg]
  name                = "${var.host_prefix}-ip-${random_id.random_id.hex}"
  location            = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
  allocation_method   = "Static"
}

# Create Network Card for linux VM
resource azurerm_network_interface rhel88-vm-nic {
  depends_on          = [azurerm_resource_group.rhel88-vm-rg]
  name                = "${var.host_prefix}-nic-${random_id.random_id.hex}"
  location            = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rhel88-vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rhel88-vm-ip.id
  }
}


####################################################################
# Create a Linux VM and provision the public SSH key
####################################################################
resource azurerm_linux_virtual_machine rhel88-vm {
  depends_on            = [
    azurerm_network_interface.rhel88-vm-nic,
    azurerm_key_vault_secret.ssh_public_key,
    azurerm_key_vault_secret.ssh_private_key
  ]
  location              = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name   = azurerm_resource_group.rhel88-vm-rg.name
  name                  = local.hostname
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.rhel88-vm-nic.id]
  size                  = var.linux_vm_size
  source_image_reference {
    offer     = var.linux_vm_image_offer
    publisher = var.linux_vm_image_publisher
    sku       = var.rhel_8_8_gen2_sku
    version   = "latest"
  }
  os_disk {
    name                 = "${var.host_prefix}-osdisk-${random_id.random_id.hex}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "80"
  }
  admin_ssh_key {
    username   = var.linux_username
    public_key = azurerm_key_vault_secret.ssh_public_key.value
  }
  admin_username = var.linux_username
  custom_data    = base64encode(templatefile("${path.module}/init_script.tpl", { VM_USERNAME = "${var.linux_username}" }))

  provisioner local-exec {
    command = templatefile("${local.host_os}_ssh_vscode.tpl", {
      hostname     = self.public_ip_address
      user         = var.linux_username
      username     = data.external.host_username.result.username
      identityfile = pathexpand("${path.cwd}/ssh/${var.ssh_key_name}.pem")
    })

    interpreter = local.host_os == "windows" ? ["powershell.exe", "-command"] : ["bash", "-c"]
  }

  provisioner file {
    source      = "${path.module}/etc/"
    destination = "/home/${var.linux_username}/"
    connection {
      type        = "ssh"
      user        = self.admin_username
      private_key = azurerm_key_vault_secret.ssh_private_key.value
      host        = self.public_ip_address
    }
  }

  tags = {
    environment = var.tag_env
  }
}


#####################################################################
# Write private SSH key to local file [ssh/${var.ssh_key_name}.pem]
#####################################################################
resource local_sensitive_file vm-ssh-private-key {
  depends_on      = [azurerm_key_vault_secret.ssh_private_key]
  file_permission = 0400
  filename        = "${path.module}/ssh/${var.ssh_key_name}.pem"
  content         = azurerm_key_vault_secret.ssh_private_key.value
}


####################################################################
# Data Collection Rule (Syslog) Association
####################################################################
# Associate the Data Collection Rule (Syslog) w/ Linux VM (Resource)
# Pull in provisioned Syslog DCR from TF Remote State (line 93)
resource azurerm_monitor_data_collection_rule_association syslog-dcra {
  name                    = "dcra-${azurerm_linux_virtual_machine.rhel88-vm.name}"
  target_resource_id      = azurerm_linux_virtual_machine.rhel88-vm.id
  data_collection_rule_id = data.terraform_remote_state.az_tf_syslog_dcr.outputs.data_collection_rule_id
}


##########################################################
# Local variables and data sources
##########################################################
locals {
  os       = data.external.os.result.os
  host_os  = local.os == "windows" ? "windows" : "linux"
  hostname = "${var.host_prefix}-syslog-${random_string.rstring.result}"
}

data azurerm_public_ip rhel88-vm-ip-data {
  name                = azurerm_public_ip.rhel88-vm-ip.name
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
}

data http my-home-ip {
  url = "https://ipv4.icanhazip.com"
}

data external host_username {
  program = local.os == "windows" ? ["powershell.exe", "-c", "${path.module}/get_host_user.ps1"] : ["bash", "${path.module}/get_host_user.sh"]
}

data external os {
  working_dir = path.module
  program     = ["printf", "{\"os\": \"linux\"}"]
}

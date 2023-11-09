# Configure the Azure provider
terraform {
  required_version = "~> 1.6.3"
  required_providers {
    azurerm  = {
      source  = "hashicorp/azurerm"
      version = "~> 3.79.0"
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
    key                  = "secops-00-vm-syslog.tfstate"
  }
}

provider azurerm {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  use_msi         = true
  environment     = var.cloud_environment              # Cloud Types: Public, USGovernment, etc
  client_id       = data.terraform_remote_state.key_vault.outputs.user_assigned_identity_client_id
  msi_endpoint    = var.user_assigned_identity_endpoint
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

# Obtain Key Vault IOT store SSH Keys
data terraform_remote_state key_vault {
  backend = "azurerm"
  config = {
    storage_account_name = "satfdev0ps1702"
    resource_group_name  = "rg-terraform-devops"
    container_name       = "tfstate"
    key                  = "key-vault-vm-ssh-keys.tfstate"

  }
}

# V-NET Peering between Syslog Collector (RHEL88) and Client (secops)
data terraform_remote_state rhel88_vnet {
  backend = "azurerm"
  config = {
    storage_account_name = "satfdev0ps1702"
    resource_group_name  = "rg-terraform-devops"
    container_name       = "tfstate"
    key                  = "rhel88-vm-syslog.tfstate"

  }
}

# Bring in current client configuration
data azurerm_client_config current {}

# Generate a random vm name
resource random_string rstring {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource azurerm_resource_group secops {
  depends_on = [random_string.rstring]
  name       = "${var.basename}rg-${random_string.rstring.result}"
  location   = var.location
  tags = {
    environment = var.tag_env
  }
}

resource random_uuid get-uuid {}

resource random_id random_id {
  keepers = {
    resource_group = azurerm_resource_group.secops.name
  }
  byte_length = 8
}

####################################################################
# Obtain provisioned key vault and store the ssh keys in the vault
####################################################################
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
resource azurerm_virtual_network secops-vnet {
  name                = "${var.basename}vnet-${random_id.random_id.hex}"
  resource_group_name = azurerm_resource_group.secops.name
  location            = azurerm_resource_group.secops.location
  address_space       = [var.network_vnet_cidr]
  tags = {
    environment = var.tag_env
  }
}

resource azurerm_subnet secops-subnet {
  name                 = "${var.basename}subnet-${random_id.random_id.hex}"
  resource_group_name  = azurerm_resource_group.secops.name
  virtual_network_name = azurerm_virtual_network.secops-vnet.name
  address_prefixes     = [var.vm_subnet_cidr]
}

resource azurerm_network_security_group secops-nsg {
  name                = "${var.basename}nsg-${random_id.random_id.hex}"
  location            = azurerm_resource_group.secops.location
  resource_group_name = azurerm_resource_group.secops.name
  tags = {
    environment = var.tag_env
  }
}

resource azurerm_network_security_rule secops-dev-ssh-rule {
  name                        = "${var.basename}ssh-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${chomp(data.http.wan_ip.response_body)}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.secops.name
  network_security_group_name = azurerm_network_security_group.secops-nsg.name
}

resource azurerm_subnet_network_security_group_association secops-subnet-nsg {
  subnet_id                 = azurerm_subnet.secops-subnet.id
  network_security_group_id = azurerm_network_security_group.secops-nsg.id
}

resource azurerm_public_ip secops_ip {
  name                = "${var.basename}ip-${random_id.random_id.hex}"
  location            = azurerm_resource_group.secops.location
  resource_group_name = azurerm_resource_group.secops.name
  allocation_method   = "Dynamic"
  tags = {
    environment = var.tag_env
  }
}

resource azurerm_network_interface secops-nic {
  depends_on = [ azurerm_public_ip.secops_ip ]
  name                = "${var.basename}nic-${random_id.random_id.hex}"
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


####################################################################
# Create a Linux VM and assign it the public SSH key
####################################################################
resource azurerm_linux_virtual_machine secops-linux-vm {
  depends_on = [
    azurerm_network_interface.secops-nic,
    azurerm_key_vault_secret.ssh_public_key,
    azurerm_key_vault_secret.ssh_private_key
  ]
  name                  = local.hostname
  resource_group_name   = azurerm_resource_group.secops.name
  location              = azurerm_resource_group.secops.location
  size                  = var.linux_vm_size
  admin_username        = var.vm_username
  network_interface_ids = [azurerm_network_interface.secops-nic.id]

  custom_data = base64encode(templatefile("${path.module}/init_script.tpl", { VM_USERNAME = "${var.vm_username}" }))

  admin_ssh_key {
    username   = var.vm_username
    public_key = azurerm_key_vault_secret.ssh_public_key.value
  }

  os_disk {
    name                 = "${var.basename}vm-osdisk-${random_id.random_id.hex}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "80"
  }

  source_image_reference {
    publisher = var.linux_vm_image_publisher
    offer     = var.linux_vm_image_offer
    sku       = var.ubun_22_04_gen2_sku
    version   = "latest"
  }
 
  provisioner local-exec {
    command = templatefile("${local.host_os}_ssh_vscode.tpl", {
      hostname     = self.public_ip_address
      user         = var.vm_username
      username     = data.external.host_username.result.username
      identityfile = pathexpand("${path.cwd}/ssh/${var.ssh_key_name}.pem")
    })

    interpreter = local.host_os == "windows" ? ["powershell.exe", "-command"] : ["bash", "-c"]
  }

  # Move's 50-default.conf in /etc/rsyslog.d to the system's location
  # This conf file is set to forward it's auth & authpriv syslog to 10.120.1.4 (Syslog Collector Private IP)
  # TCP on port 20514 bec that's the rsyslog port pre-defined on RHEL 8.
  provisioner file {
    source      = "${path.module}/etc/rsyslog.d/50-default.conf"
    destination = "/home/${var.vm_username}/50-default.conf"
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
  filename        = "${path.module}/ssh/${var.ssh_key_name}.pem"
  file_permission = 0400
  content         = azurerm_key_vault_secret.ssh_private_key.value
}


##########################################################
# VNET Peering beteween secops and syslog server vnets
##########################################################
# Remote ID: secops vnet id
resource "azurerm_virtual_network_peering" "syslogsvr" {
  name                      = var.rhel88_to_secops
  resource_group_name       = data.terraform_remote_state.rhel88_vnet.outputs.rhel88_rg_name
  virtual_network_name      = data.terraform_remote_state.rhel88_vnet.outputs.rhel88_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.secops-vnet.id
}

# Remote ID: syslog server vnet id
resource "azurerm_virtual_network_peering" "syslogclient" {
  name                      = var.secops_to_rhel88
  resource_group_name       = azurerm_resource_group.secops.name
  virtual_network_name      = azurerm_virtual_network.secops-vnet.name
  remote_virtual_network_id = data.terraform_remote_state.rhel88_vnet.outputs.rhel88_vnet_id
}


##########################################################
# Local variables and data sources
##########################################################
locals {
  os       = data.external.os.result.os
  host_os  = local.os == "windows" ? "windows" : "linux"
  hostname = "${var.basename}vm-${random_string.rstring.result}"
}

data http wan_ip {
  url = "http://ipv4.icanhazip.com"
}

data external host_username {
  program = local.os == "windows" ? ["powershell.exe", "-c", "${path.module}/get_host_user.ps1"] : ["bash", "${path.module}/get_host_user.sh"]
}

data external os {
  working_dir = path.module
  program     = ["printf", "{\"os\": \"linux\"}"]
}

# Provide the provisioned public IP address to the user via output (STDOUT)
data azurerm_public_ip secops {
  name                = azurerm_public_ip.secops_ip.name
  resource_group_name = azurerm_linux_virtual_machine.secops-linux-vm.resource_group_name
}

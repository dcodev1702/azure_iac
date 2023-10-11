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
data azurerm_key_vault main {
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


####################################################################
# Create a virtual network, subnet, NSG, and public IP for the VM
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
# Create a Linux VM and provision the public SSH key
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
# Bring in the syslog server vnet
data azurerm_virtual_network syslog_server {
  name                = var.syslog_server_vnet
  resource_group_name = var.syslog_server_rg
}

# Remote ID: secops vnet id
resource "azurerm_virtual_network_peering" "syslogsvr" {
  name                      = "devops2secops"
  resource_group_name       = var.syslog_server_rg
  virtual_network_name      = data.azurerm_virtual_network.syslog_server.name
  remote_virtual_network_id = azurerm_virtual_network.secops-vnet.id
}

# Remote ID: syslog server vnet id
resource "azurerm_virtual_network_peering" "syslogclient" {
  name                      = "secops2devops"
  resource_group_name       = azurerm_resource_group.secops.name
  virtual_network_name      = azurerm_virtual_network.secops-vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.syslog_server.id
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

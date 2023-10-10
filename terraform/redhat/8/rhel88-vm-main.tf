# Generate a random vm name
resource "random_string" "rstring" {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

# Provision Resource Group (RG) for RHEL 8 deployment
resource "azurerm_resource_group" "rhel88-vm-rg" {
  depends_on = [random_string.rstring]
  name       = "rhel88-vm-tf-rg-${random_string.rstring.result}"
  location   = var.location
  tags = {
    environment = var.tag_env
  }
}

resource "random_uuid" "get-uuid" {}

resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.rhel88-vm-rg.name
  }
  byte_length = 8
}

# Bring in Key Vault where SSH keys will reside
data "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

# SSH Key Cipher / Strength
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

resource "azurerm_virtual_network" "rhel88-vm-vnet" {
  name                = "rhel88-vm-tf-vnet-${random_id.random_id.hex}"
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
  location            = azurerm_resource_group.rhel88-vm-rg.location
  address_space       = [var.network_vnet_cidr]
  tags = {
    environment = var.tag_env
  }
}

# Create a subnet for Network
resource "azurerm_subnet" "rhel88-vm-subnet" {
  name                 = "rhel88-vm-tf-subnet"
  address_prefixes     = [var.vm_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.rhel88-vm-vnet.name
  resource_group_name  = azurerm_resource_group.rhel88-vm-rg.name
}

# Create Security Group to access linux
resource "azurerm_network_security_group" "rhel88-vm-nsg" {
  depends_on          = [azurerm_resource_group.rhel88-vm-rg]
  name                = "rhel88-vm-tf-nsg-${random_id.random_id.hex}"
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
resource "azurerm_subnet_network_security_group_association" "rhel88-vm-nsg-association" {
  depends_on                = [azurerm_resource_group.rhel88-vm-rg]
  subnet_id                 = azurerm_subnet.rhel88-vm-subnet.id
  network_security_group_id = azurerm_network_security_group.rhel88-vm-nsg.id
}

# Get a Static Public IP
resource "azurerm_public_ip" "rhel88-vm-ip" {
  depends_on          = [azurerm_resource_group.rhel88-vm-rg]
  name                = "rhel88-vm-tf-ip-${random_id.random_id.hex}"
  location            = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
  allocation_method   = "Static"
}

# Create Network Card for linux VM
resource "azurerm_network_interface" "rhel88-vm-nic" {
  depends_on          = [azurerm_resource_group.rhel88-vm-rg]
  name                = "rhel88-vm-tf-nic-${random_id.random_id.hex}"
  location            = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rhel88-vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rhel88-vm-ip.id
  }
}

# Create Linux VM with linux server
resource "azurerm_linux_virtual_machine" "rhel88-vm" {
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
    name                 = "rhel88-vm-osdisk-${random_id.random_id.hex}"
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

  provisioner "local-exec" {
    command = templatefile("${local.host_os}_ssh_vscode.tpl", {
      hostname     = self.public_ip_address
      user         = var.linux_username
      username     = data.external.host_username.result.username
      identityfile = pathexpand("${path.module}/ssh/${var.ssh_key_name}.pem")
    })

    interpreter = local.host_os == "windows" ? ["powershell.exe", "-command"] : ["bash", "-c"]
  }

  provisioner "file" {
    source      = "${path.module}/etc/rsyslog.d/00-remotelog.conf"
    destination = "/home/${var.linux_username}/00-remotelog.conf"
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

locals {
  os       = data.external.os.result.os
  host_os  = local.os == "windows" ? "windows" : "linux"
  hostname = "rhel88-vm-syslog-tf-${random_string.rstring.result}"
}

data "azurerm_public_ip" "rhel88-vm-ip-data" {
  name                = azurerm_public_ip.rhel88-vm-ip.name
  resource_group_name = azurerm_resource_group.rhel88-vm-rg.name
}

data "http" "my-home-ip" {
  url = "https://ipv4.icanhazip.com"
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
resource "local_sensitive_file" "vm-ssh-private-key" {
  depends_on      = [azurerm_key_vault_secret.ssh_private_key]
  filename        = "${path.module}/ssh/${var.ssh_key_name}.pem"
  file_permission = 0400
  content         = azurerm_key_vault_secret.ssh_private_key.value
}

# We use the private key to connect to the Azure VM
resource "local_file" "vm-ssh-private-key" {
  depends_on = [null_resource.create_ssh_dir] 
  content    = azurerm_key_vault_secret.ssh_private_key.value
  filename   = "${path.module}/ssh/${var.ssh_key_name}.pem"
}

resource "null_resource" "set-perms-ssh_key" {
  depends_on = [local_file.vm-ssh-private-key]
  provisioner "local-exec" {
    command = local.host_os == "linux" ? "chmod 400 ${path.module}/ssh/${var.ssh_key_name}.pem" : "icacls.exe ${path.module}\\ssh\\${var.ssh_key_name}.pem /inheritance:r"
    interpreter = local.host_os == "linux" ? ["bash", "-c"] : ["powershell.exe", "-command"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Identify the Data Collection Rule (Syslog) for association
data azurerm_monitor_data_collection_rule syslog-dcr {
  name                = var.syslog_dcr_name
  resource_group_name = var.dcr_resource_group_name
}

# Associate the Data Collection Rule (Syslog) with the Linux VM
resource azurerm_monitor_data_collection_rule_association syslog-dcra {
  name                    = "dcra-${azurerm_linux_virtual_machine.rhel88-vm.name}"
  target_resource_id      = azurerm_linux_virtual_machine.rhel88-vm.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.syslog-dcr.id
}

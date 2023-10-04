# Generate a random vm name
resource "random_string" "network-security-random" {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource "azurerm_resource_group" "rhel88-vm-rg" {
  name     = "rhel88-vm-tf-rg"
  location = "eastus"
  tags = {
    environment = var.tag_env
  }
}

resource "random_uuid" "get-uuid" {}

resource "random_id" "random_id" {
  byte_length = 8
}

resource "azurerm_virtual_network" "rhel88-vm-vnet" {
  name                = "rhel88-vm-tf-vnet"
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
  name                = "rhel88-vm-tf-nsg"
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
    destination_port_range     = "514"
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
    destination_port_range     = "514"
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
    destination_port_range     = "22"
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
  depends_on            = [azurerm_network_interface.rhel88-vm-nic]
  location              = azurerm_resource_group.rhel88-vm-rg.location
  resource_group_name   = azurerm_resource_group.rhel88-vm-rg.name
  name                  = "rhel88-vm-syslog-tf-01"
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
    public_key = file(pathexpand("~/.ssh/${var.ssh_key_name}.pub"))
  }
  admin_username = var.linux_username
  custom_data    = base64encode(templatefile("${path.module}/init_script.tpl", { VM_USERNAME = "${var.linux_username}" }))

  provisioner "local-exec" {
    command = templatefile("${local.host_os}_ssh_vscode.tpl", {
      hostname     = self.public_ip_address
      user         = var.linux_username
      username     = data.external.host_username.result.username
      identityfile = pathexpand("~/.ssh/${var.ssh_key_name}")
    })

    interpreter = local.host_os == "windows" ? ["powershell.exe", "-command"] : ["bash", "-c"]
  }

  provisioner "file" {
    source       = "${path.module}/etc/rsyslog.d/00-remotelog.conf"
    destination  = "/home/${var.linux_username}/00-remotelog.conf"
    #on_failure  = continue
    connection {
      type        = "ssh"
      user        = self.admin_username
      private_key = file("${path.module}/ssh/rhel88-rsyslog-azure")
      host        = self.public_ip_address
      #agent      = false
    }
  }

  tags = {
    environment = var.tag_env
  }
}

locals {
  os      = data.external.os.result.os
  host_os = local.os == "windows" ? "windows" : "linux"
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

output "host_username" {
  value = data.external.host_username.result.username
}

output "local_host_os" {
  value = local.host_os
}

output "vm_username_bash_script" {
  value = var.linux_username
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.rhel88-vm.name}: ${data.azurerm_public_ip.rhel88-vm-ip-data.ip_address}"
}

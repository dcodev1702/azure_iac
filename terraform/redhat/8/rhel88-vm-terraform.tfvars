# Linux VM
linux_vm_size            = "Standard_D2as_v4"
linux_username           = "dcodev"
ssh_key_name             = "rhel88-rsyslog-azure"
location                 = "eastus"
linux_vm_image_publisher = "RedHat"
linux_vm_image_offer     = "RHEL"
rhel_8_8_gen2_sku        = "88-gen2"
tag_env                  = "rhel88_syslog_collector"
host_prefix              = "rhel88-vm-tf"
cloud_environment        = "public"

# Network
network_vnet_cidr = "10.120.0.0/16"
vm_subnet_cidr    = "10.120.1.0/24"

# Network Security Group Rules
ssh_port          = "22"
syslog_tcp        = "20514"
syslog_udp        = "514"

# Data Collection Rule & Association
syslog_dcr_name         = "Linux-Syslog-0"
dcr_resource_group_name = "sec_telem_law_1"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_guid = ""

# Azure Login via Managed Identity (User-Assigned)
azure_subscription_id   = ""
azure_tenant_id         = ""

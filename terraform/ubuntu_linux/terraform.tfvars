# Azure Core (Infra)
linux_vm_size            = "Standard_D2as_v4"
basename                 = "secops-tf-"
linux_vm_image_publisher = "Canonical"
linux_vm_image_offer     = "0001-com-ubuntu-server-jammy" 
ubun_22_04_gen2_sku      = "22_04-lts-gen2"
vm_username              = "dcodev"
ssh_key_name             = "secops-linux-tf"
location                 = "eastus"
tag_env                  = "dev"
cloud_environment        = "public"

# Syslog Server VNET Peering
rhel88_to_secops = "syslogsvr2secops"
secops_to_rhel88 = "secops2syslogsvr"

# Network
network_vnet_cidr = "10.123.0.0/16"
vm_subnet_cidr    = "10.123.1.0/24"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_guid     = ""
user_assigned_identity_endpoint = "http://169.254.169.254/metadata/identity/oauth2/token"

# Azure Login via Managed Identity (User-Assigned)
azure_subscription_id = ""
azure_tenant_id       = ""

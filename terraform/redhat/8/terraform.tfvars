# Linux VM
linux_vm_size            = "Standard_D2as_v4"
linux_username           = "dcodev"
ssh_key_name             = "rhel88-rsyslog-azure"
location                 = "eastus"
linux_vm_image_publisher = "RedHat"
linux_vm_image_offer     = "RHEL"
rhel_8_8_gen2_sku        = "88-gen2"

# Network
network_vnet_cidr = "10.120.0.0/16"
vm_subnet_cidr    = "10.120.1.0/24"

# Network Security Group Rules
ssh_port          = "22"
syslog_tcp        = "20514"
syslog_udp        = "514"

# Key Vault Information
key_vault_name                = "kv-ssh-keys-22y3spqd"
key_vault_resource_group_name = "rg-kv-22y3spqd"

# Data Collection Rule & Association
syslog_dcr_name         = "Linux-Syslog-0"
dcr_resource_group_name = "sec_telem_law_1"

# Azure Login via Service Principal (SP)
# export SUBSCRIPTION_ID="ENTER_YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id   = ""
azure_client_id         = ""
azure_client_secret     = ""
azure_tenant_id         = ""

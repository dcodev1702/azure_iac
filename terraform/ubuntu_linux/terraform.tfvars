# Azure Core
linux_vm_size     = "Standard_D2as_v4"
vm_username       = "dcodev"
ssh_key_name      = "secops-linux-tf"
location          = "eastus"
tag_env           = "dev"

# Network
network_vnet_cidr = "10.123.0.0/16"
vm_subnet_cidr    = "10.123.1.0/24"

# Key Vault Information
key_vault_name                = "kv-vm-ssh-keys-0ftahiij"
key_vault_resource_group_name = "rg-kv-0ftahiij"

# Azure Login via Service Principal (SP)
# SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_client_id       = ""
azure_client_secret   = ""
azure_tenant_id       = ""

# Network
network_vnet_cidr = "10.120.0.0/16"
vm_subnet_cidr    = "10.120.1.0/24"

# Linux VM
linux_vm_size  = "Standard_D2as_v4"
linux_username = "dcodev"
ssh_key_name   = "rhel88-rsyslog-azure"

# Azure Login via Service Principal (SP)
# export SUBSCRIPTION_ID="ENTER_YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_client_id       = ""
azure_client_secret   = ""
azure_tenant_id       = ""

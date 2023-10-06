# SSH Key
ssh_key_name = "kv-ssh-vm"
tag_env      = "keyvault_ssh_key"
kv_location  = "eastus"

# Azure Login via Service Principal (SP)
# SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_client_id       = ""
azure_client_secret   = ""
azure_tenant_id       = ""

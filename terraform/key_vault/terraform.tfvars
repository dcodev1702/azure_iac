# Key Vault Variables
key_vault_name     = "kv-vm-ssh-keys"
tag_env            = "key_vault_ssh_key"
key_vault_location = "eastus"

# Azure Login via Service Principal (SP)
# SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_client_id       = ""
azure_client_secret   = ""
azure_tenant_id       = ""

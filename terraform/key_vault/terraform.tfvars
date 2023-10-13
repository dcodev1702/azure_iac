# Key Vault Variables
key_vault_name     = "kv-vm-ssh-keys"
tag_env            = "key_vault_ssh_keys"
key_vault_location = "eastus"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_guid = ""
user_assigned_identity_name = "AzureTerraformDev0ps"
uai_resource_group_name     = "sec_telem_law_1"


# Azure Login via Service Principal (SP)
# SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_tenant_id       = ""

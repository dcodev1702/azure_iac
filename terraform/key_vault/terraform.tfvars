# Key Vault Variables
key_vault_name     = "kv-vm-ssh-keys"
tag_env            = "key_vault_ssh_keys"
key_vault_location = "eastus"
cloud_environment  = "public"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_guid     = ""
user_assigned_identity_endpoint = "http://169.254.169.254/metadata/identity/oauth2/token"
user_assigned_identity_name     = "AzureTerraformDev0ps"
uai_resource_group_name         = "sec_telem_law_1"


# Azure Login via Managed Identity (User-Assigned)
azure_subscription_id = ""
azure_tenant_id       = ""

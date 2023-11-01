# Azure Resource Group Information
location            = "eastus"
resource_group_name = "rg-terraform-devops"
cloud_environment   = "public"

# Storage Account Information
storage_account_name  = "satfdev0ps1702"

# Terraform Backend Container Information
sa_container_name     = "tfstate"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_guid     = ""
user_assigned_identity_endpoint = "http://169.254.169.254/metadata/identity/oauth2/token"
user_assigned_identity_name     = "AzureTerraformDev0ps"
uai_resource_group_name         = "sec_telem_law_1"


# Azure Login via Managed Identity (User-Assigned)
azure_subscription_id = ""
azure_tenant_id       = ""

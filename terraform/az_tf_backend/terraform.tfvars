# Azure Resource Group Information
location            = "eastus"
resource_group_name = "rg-terraform-devops"
cloud_environment   = "public"

# Storage Account Information
storage_account_name  = "satfdev0ps1702"
storage_account_rg    = "rg-storage-terraform-devops"
storage_account_sku   = "Standard_LRS"

# Terraform Backend Container Information
sa_container_name     = "tfstate"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_guid = ""

# Azure Login via Service Principal (SP)
# subsriptionId="$(az account list --query "[?isDefault].id" --output tsv)"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" --name="AZTFDevOps"
azure_subscription_id = ""
azure_tenant_id       = ""

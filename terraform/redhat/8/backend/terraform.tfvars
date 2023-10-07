# Azure Resource Group Information
location = "eastus"
resource_group_name = "rg-terraform-devops"

# Storage Account Information
storage_account_name = "satfdevops"
storage_account_rg   = "rg-storage-terraform-devops"
storage_account_sku  = "Standard_LRS"

# Terraform Backend Container Information
sa_container_name = "tfstate"

# Azure Login via Service Principal (SP)
# SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_client_id       = ""
azure_client_secret   = ""
azure_tenant_id       = ""

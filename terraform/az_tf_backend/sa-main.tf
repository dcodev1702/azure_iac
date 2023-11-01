# Define Terraform provider
terraform {
  required_version = "~> 1.6.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.78.0"
    }
  }
}

# Managed User-Assigned Identity has already been provisioned
# https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp#create-a-user-assigned-managed-identity
# Configure the Azure provider
provider azurerm {
  features {}
  use_msi          = true
  environment      = var.cloud_environment
  client_id        = var.user_assigned_identity_guid
  msi_endpoint     = var.user_assigned_identity_endpoint
  subscription_id  = var.azure_subscription_id
  tenant_id        = var.azure_tenant_id
}

resource azurerm_resource_group main {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.tag_env
  }
}

data azurerm_client_config current {}

# Obtain User Managed Identity to provision Key Vault / Secrets
data azurerm_user_assigned_identity user_msi {
  name                = var.user_assigned_identity_name
  resource_group_name = var.msi_resource_group_name
}

resource azurerm_storage_account main {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false
  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.user_msi.id
    ]
  }
  blob_properties {
    last_access_time_enabled = true
  }
}

resource azurerm_storage_container tfstate {
  name                  = var.sa_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

output user_assigned_identity_client_id {
  value = data.azurerm_user_assigned_identity.user_msi.client_id
}

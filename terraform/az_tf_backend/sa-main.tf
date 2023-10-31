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

# Configure the Azure provider
provider azurerm {
  features {}
  use_msi          = true
  environment      = var.cloud_environment
  client_id        = var.user_assigned_identity_guid
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

#data "azurerm_subscription" "primary" {}
data azurerm_client_config current {}

#data azurerm_role_definition builtin_blob_owner {
#  name = "Storage Blob Data Owner"
#}

# Obtain User Managed Identity to provision Key Vault / Secrets
data azurerm_user_assigned_identity user_msi {
  name                = var.user_assigned_identity_name
  resource_group_name = var.msi_resource_group_name
}

#resource azurerm_role_assignment assign_identity_storage_blob_data_owner {
#  scope                = azurerm_storage_account.main.id
#  role_definition_id   = data.azurerm_role_definition.builtin_blob_owner.id
#  principal_id         = data.azurerm_user_assigned_identity.user_msi.principal_id
#}

resource azurerm_storage_account main {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
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

#output role {
#  value = data.azurerm_role_definition.builtin_blob_owner.role_definition_id
#}

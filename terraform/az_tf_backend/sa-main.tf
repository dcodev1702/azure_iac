# Define Terraform provider
terraform {
  required_version = "~> 1.6.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }
}

# Configure the Azure provider
provider azurerm {
  features {}
  use_msi         = true
  environment     = var.cloud_environment
  client_id       = var.user_assigned_identity_guid
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

resource azurerm_resource_group main {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.tag_env
  }
}

resource azurerm_storage_account main {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS" 
}

resource azurerm_storage_container tfstate {
  name                  = var.sa_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

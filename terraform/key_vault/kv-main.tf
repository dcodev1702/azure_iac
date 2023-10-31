# Define Terraform provider
terraform {
  required_version = "~> 1.6.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.78.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
  }
  backend azurerm {
    resource_group_name  = "rg-terraform-devops"
    storage_account_name = "satfdev0ps1702"
    container_name       = "tfstate"
    key                  = "key-vault-vm-ssh-keys.tfstate"
  }
}

# Configure the Azure provider
provider azurerm {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  use_msi         = true
  environment     = var.cloud_environment  # Cloud Environment [public, usgovernment]
  client_id       = var.user_assigned_identity_guid
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Generate a random vm name
resource random_string main {
  length  = 8
  numeric = true
  lower   = true
  upper   = false
  special = false
}


resource azurerm_resource_group main {
  name     = "rg-kv-${random_string.main.result}"
  location = var.key_vault_location
  tags = {
    environment = var.tag_env
  }
}

# Create Key Vault where SSH Keys will be stored (secrets)
resource azurerm_key_vault main {
  name                            = "${var.key_vault_name}-${random_string.main.result}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  tenant_id                       = var.azure_tenant_id
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false
  purge_protection_enabled        = false

  sku_name = "standard"
  tags = {
    environment = var.tag_env
  }
}

# Obtain User Managed Identity to provision Key Vault / Secrets
data azurerm_user_assigned_identity user_msi {
  name                = var.user_assigned_identity_name
  resource_group_name = var.uai_resource_group_name
}

# Assign the SP to the Key Vaul Access Policy for proper access to 'secrets'
# where VM SSH Keys will be stored.
resource azurerm_key_vault_access_policy user_msi {
  depends_on   = [
    azurerm_key_vault.main,
    data.azurerm_user_assigned_identity.user_msi
  ]
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.azure_tenant_id
  object_id    = data.azurerm_user_assigned_identity.user_msi.principal_id

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

# Output name of Key Vault and add to variable.tf and terraform.tfvars
# for Ubuntu and RHEL VM's so you can create and store SSH Keys in this Key Vault.
output key_vault_name {
  value = azurerm_key_vault.main.name
}
output key_vault_id {
  value = azurerm_key_vault.main.id
}

# Generate a random vm name
resource random_string main {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}


data azurerm_client_config current {}

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
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false
  purge_protection_enabled        = false

  sku_name = "standard"
  tags = {
    environment = var.tag_env
  }
}

# Obtain SP so it has the necessary access to the Key Vault / Secrets
data azuread_service_principal sp_app {
    display_name = "AzureTerraformDevOps"
}

# Assign the SP to the Key Vaul Access Policy for proper access to 'secrets'
# where VM SSH Keys will be stored.
resource azurerm_key_vault_access_policy sp_app {
  depends_on   = [
    azurerm_key_vault.main,
    data.azuread_service_principal.sp_app
  ]
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.sp_app.object_id

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

# Output name of Key Vault and add to variable.tf and terraform.tfvars
# for Ubuntu and RHEL VM's so you can create and store SSH Keys in this Key Vault.
output new_key_vault {
  description = "Name of newly created Key Vault that will store SSH Keys (secrets)"
  value       = azure_key_vault.main.name
}

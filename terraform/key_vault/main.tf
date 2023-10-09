# Generate a random vm name
resource random_string main {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

#resource tls_private_key main {
#  algorithm  = "RSA"
#  rsa_bits   = 4096
#}

data azurerm_client_config current {}

resource azurerm_resource_group main {
  name     = "rg-kv-${random_string.main.result}"
  location = var.kv_location
  tags = {
    environment = var.tag_env
  }
}

resource azurerm_key_vault main {
  name                            = "kv-ssh-key-${random_string.main.result}"
  location                        = var.kv_location
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

data azuread_service_principal sp_app {
    display_name = "AzureTerraformDevOps"
}


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


# Create a secret (ssh public key) in the key vault
#resource azurerm_key_vault_secret ssh_public_key {
#  depends_on   = [
#    azurerm_key_vault.main,
#    tls_private_key.main,
#    azurerm_key_vault_access_policy.sp_app
#  ]
#  key_vault_id = azurerm_key_vault.main.id
#  name         = "ssh-public-key"
#  value        = tls_private_key.main.public_key_openssh
#}

# Create a secret (ssh private key) in the key vault
#resource azurerm_key_vault_secret ssh_private_key {
#  depends_on   = [
#    azurerm_key_vault.main,
#    tls_private_key.main,
#    azurerm_key_vault_access_policy.sp_app
#  ]
#  key_vault_id = azurerm_key_vault.main.id
#  name         = "ssh-private-key"
#  value        = tls_private_key.main.private_key_pem
#}

# Save the private key to your local machine
# Save the public key to your your Azure VM
# We use the private key to connect to the Azure VM
#resource "local_file" "ssh-private-key" {
#  content = azurerm_key_vault_secret.ssh_private_key.value
#  filename = "${path.module}/ssh/${var.ssh_key_name}.pem"
#}
#resource "local_file" "ssh-public-key" {
#  content = azurerm_key_vault_secret.ssh_public_key.value
#  filename = "${path.module}/ssh/${var.ssh_key_name}.pub"
#}

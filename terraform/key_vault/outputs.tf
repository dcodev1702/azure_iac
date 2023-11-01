# Output name of Key Vault and add to variable.tf and terraform.tfvars
# for Ubuntu and RHEL VM's so you can create and store SSH Keys in this Key Vault.
output key_vault_name {
  value = azurerm_key_vault.main.name
}
output key_vault_id {
  value = azurerm_key_vault.main.id
}
output user_assigned_identity_client_id {
  value = data.azurerm_user_assigned_identity.user_msi.client_id
}

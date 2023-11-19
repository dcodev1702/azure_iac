# Output Data Collection Rule & Log-A info
output "log_analytics_workspace_id" {
  value = data.azurerm_log_analytics_workspace.main.id
}
output "log_analytics_workspace_name" {
  value = data.azurerm_log_analytics_workspace.main.name
}
output "data_collection_rule_name" {
  value = azurerm_monitor_data_collection_rule.main.name
}
output "data_collection_rule_id" {
  value = azurerm_monitor_data_collection_rule.main.id
}
output user_assigned_identity_client_id {
  value = data.azurerm_user_assigned_identity.user_msi.client_id
}

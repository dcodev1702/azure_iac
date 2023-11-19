variable azure_subscription_id {
  type        = string
  description = "Azure Subscription ID"
}
variable azure_tenant_id {
  type        = string
  description = "Azure Tenant ID"
}
variable tag_env {
  type        = string
  description = "Environment Tag"
}
variable dcr_syslog_name {
  type        = string
  description = "Name of Data Collection Rule"
}
variable dcr_syslog_location {
  type        = string
  description = "Location of Data Collection Rule"
}
variable log_analytics_workspace_name {
  type        = string
  description = "Name of Log-A Workspace"
}
variable log_analytics_workspace_rg {
  type        = string
  description = "Log-A Resource Group"
}
variable user_assigned_identity_name {
  type        = string
  description = "User Assigned Identity"
}
variable user_assigned_identity_guid {
  type        = string
  description = "User Assigned Identity GUID"
}
variable uai_resource_group_name {
  type        = string
  description = "User Assigned Identity Resource Group"
}
variable cloud_environment {
  type        = string
  description = "Cloud Environment"
}
variable user_assigned_identity_endpoint {
  type        = string
  description = "MSI Endpoint"
}

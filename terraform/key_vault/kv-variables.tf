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
variable key_vault_name {
  type        = string
  description = "Name of Key Vault"
}
variable key_vault_location {
  type        = string
  description = "Location of Key Vault"
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

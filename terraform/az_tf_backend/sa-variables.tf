variable azure_subscription_id {
  type        = string
  description = "Azure Subscription ID"
}
variable azure_tenant_id {
  type        = string
  description = "Azure Tenant ID"
}
variable location {
  type        = string
  description = "Azure Commercial Region"
}
variable resource_group_name {
  type        = string
  description = "Azure Resource Group Name"
}
variable storage_account_name {
  type        = string
  description = "Azure Storage Account Name"
}
variable sa_container_name {
  type        = string
  description = "Azure Storage Account Container Name"
}
variable tag_env {
  type        = string
  default     = "terraform backend storage"
}
variable user_assigned_identity_name {
  type        = string
  description = "User Assigned Identity"
}
variable user_assigned_identity_guid {
  type        = string
  description = "User Assigned Identity GUID"
}
variable msi_resource_group_name {
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

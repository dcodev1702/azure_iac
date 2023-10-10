variable "vm_username" {
  type        = string
  description = "value for the vm username"
}
variable "tag_env" {
  type        = string
  description = "value for the environment tag"
}
variable "ssh_key_name" {
  type        = string
  description = "SSH Public Key Name"
}
variable "network_vnet_cidr" {
  type        = string
  description = "The CIDR of the network VNET"
}
variable "vm_subnet_cidr" {
  type        = string
  description = "The CIDR for the network subnet"
}
variable "location" {
  type        = string
  description = "Azure Region"
}
variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}
variable "azure_client_id" {
  type        = string
  description = "Azure Client ID"
}
variable "azure_client_secret" {
  type        = string
  description = "Azure Client Secret"
}
variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}
variable "key_vault_name" {
  type        = string
  description = "Name of the keyvault"
}
variable "key_vault_resource_group_name" {
  type        = string
  description = "Name of the keyvault resource group"
}

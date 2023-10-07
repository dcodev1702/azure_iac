variable "location" {
  type        = string
  description = "Azure Commercial Region"
}
variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group Name"
}
variable "storage_account_name" {
  type        = string
  description = "Azure Storage Account Name"
}
variable "storage_account_rg" {
  type        = string
  description = "Azure Storage Account Resource Group"
}
variable "storage_account_sku" {
  type        = string
  description = "Azure Storage Account SKU"
}
variable "sa_container_name" {
  type        = string
  description = "Azure Storage Account Container Name"
}
variable "tag_env" {
  type    = string
  default = "terraform backend storage"
}

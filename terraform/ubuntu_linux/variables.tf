variable linux_vm_image_publisher {
  type        = string
  description = "Linux Distro"
}
variable linux_vm_image_offer {
  type        = string
  description = "Linux Image Offer"
}
variable ubun_22_04_gen2_sku {
  type        = string
  description = "Linux Gen - SKU"
}
variable linux_vm_size {
  type        = string
  description = "Linux VM Size"
}
variable basename {
  type        = string
  description = "Base name for the resources"
}
variable vm_username {
  type        = string
  description = "value for the vm username"
}
variable tag_env {
  type        = string
  description = "value for the environment tag"
}
variable ssh_key_name {
  type        = string
  description = "SSH Public Key Name"
}
variable network_vnet_cidr {
  type        = string
  description = "The CIDR of the network VNET"
}
variable vm_subnet_cidr {
  type        = string
  description = "The CIDR for the network subnet"
}
variable location {
  type        = string
  description = "Azure Region"
}
variable azure_subscription_id {
  type        = string
  description = "Azure Subscription ID"
}
variable azure_tenant_id {
  type        = string
  description = "Azure Tenant ID"
}
variable rhel88_to_secops {
  type        = string
}
variable secops_to_rhel88 {
  type        = string
}
variable cloud_environment {
  type        = string
  description = "Type of Cloud [public, usgovernment]"
}
variable user_assigned_identity_endpoint {
  type        = string
  description = "MSI Endpoint"
}

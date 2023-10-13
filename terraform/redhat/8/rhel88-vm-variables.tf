variable azure_subscription_id {
  type        = string
  description = "Azure Subscription ID"
}
variable azure_tenant_id {
  type        = string
  description = "Azure Tenant ID"
}
variable linux_vm_image_publisher {
  type        = string
  description = "Virtual machine source image publisher"
}
variable linux_vm_image_offer {
  type        = string
  description = "Virtual machine source image offer"
}
variable rhel_8_8_gen2_sku {
  type        = string
  description = "SKU for RHEL 8.8 Gen2"
}
variable location {
  type        = string
  description = "Azure Cloud Region"
}
variable tag_env {
  type    = string
  description = "Tag for RHEL 8 resource"
}
variable network_vnet_cidr {
  type        = string
  description = "The CIDR of the network VNET"
}
variable vm_subnet_cidr {
  type        = string
  description = "The CIDR for the network subnet"
}
variable ssh_key_name {
  type        = string
  description = "SSH Public Key Name"
}
variable linux_username {
  type        = string
  description = "Linux Username"
}
variable linux_vm_size {
  type        = string
  description = "Linux VM Size"
}
variable syslog_dcr_name {
  type        = string
  description = "Linux VM Size"
}
variable dcr_resource_group_name {
  type        = string
  description = "Linux VM Size"
}
variable ssh_port {
  type        = string
  description = "Port 22"
}
variable syslog_tcp {
  type        = string
  description = "Port 20514"
}
variable syslog_udp {
  type        = string
  description = "Port 514"
}
variable user_assigned_identity_guid {
  type = string
  description = "User Assigned Identity GUID"
}
variable cloud_environment {
  type = string
  description = "Cloud Type [public, usgovernment]"
}
variable host_prefix {
  type = string
  description = "Prefix for host when naming resources"
}

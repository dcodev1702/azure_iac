variable "linux_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "RedHat"
}
variable "linux_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "RHEL"
}
variable "rhel_8_8_gen2_sku" {
  type        = string
  description = "SKU for RHEL 8.8 Gen2"
  default     = "88-gen2"
}

variable "tag_env" {
  type    = string
  default = "rhel88_syslog_collector"
}
variable "network_vnet_cidr" {
  type        = string
  description = "The CIDR of the network VNET"
}
variable "vm_subnet_cidr" {
  type        = string
  description = "The CIDR for the network subnet"
}
variable "ssh_key_name" {
  type        = string
  description = "SSH Public Key Name"
}
variable "linux_username" {
  type        = string
  description = "Linux Username"
}
variable "linux_vm_size" {
  type        = string
  description = "Linux VM Size"
}
variable "syslog_dcr_name" {
  type        = string
  description = "Linux VM Size"
}
variable "dcr_resource_group_name" {
  type        = string
  description = "Linux VM Size"
}
variable "ssh_port" {
  type        = string
  description = "Linux VM Size"
}
variable "syslog_tcp" {
  type        = string
  description = "Linux VM Size"
}
variable "syslog_udp" {
  type        = string
  description = "Linux VM Size"
}
variable "keyvault_name" {
  type        = string
  description = "Name of the keyvault"
}
variable "keyvault_resource_group_name" {
  type        = string
  description = "Name of the keyvault resource group"
}

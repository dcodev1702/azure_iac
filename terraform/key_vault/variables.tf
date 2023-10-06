variable "tag_env" {
  type    = string
  description = "Environment Tag"
}
variable "ssh_key_name" {
  type        = string
  description = "SSH Public Key Name"
}
variable "kv_location" {
  type        = string
  description = "Location of Key Vault"
}

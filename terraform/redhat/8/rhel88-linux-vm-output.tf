##########################
## Azure Linux - Output ##
##########################

output "linux_vm_name" {
  description = "Virtual Machine name"
  value       = azurerm_linux_virtual_machine.rhel88-vm.name
}

output "linux_vm_ip_address" {
  description = "Virtual Machine name IP Address"
  value       = azurerm_public_ip.rhel88-vm-ip.ip_address
}

output "linux_vm_admin_username" {
  description = "Username password for the Virtual Machine"
  value       = var.linux_username
}

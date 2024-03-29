##########################
## Azure Linux - Output ##
##########################
output linux_vm_name {
  description = "Virtual Machine name"
  value       = azurerm_linux_virtual_machine.rhel88-vm.name
}
output linux_vm_ip_address {
  description = "Virtual Machine name IP Address"
  value       = azurerm_public_ip.rhel88-vm-ip.ip_address
}
output linux_vm_admin_username {
  description = "Username password for the Virtual Machine"
  value       = var.linux_username
}
output host_username {
  value = data.external.host_username.result.username
}
output local_host_os {
  value = local.host_os
}
output rhel88_vnet_id {
  value = azurerm_virtual_network.rhel88-vm-vnet.id
}
output rhel88_vnet_name {
  value = azurerm_virtual_network.rhel88-vm-vnet.name
}
output rhel88_rg_name {
  value = azurerm_resource_group.rhel88-vm-rg.name
}

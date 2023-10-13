output host_username {
  value = data.external.host_username.result.username
}
output local_host_os {
  value = local.host_os
}
output vm_username_bash_script {
  value = var.vm_username
}
output hostname_vm_tf {
  value = azurerm_linux_virtual_machine.secops-linux-vm.name
}
output public_ip_address {
  value = data.azurerm_public_ip.secops.ip_address
}

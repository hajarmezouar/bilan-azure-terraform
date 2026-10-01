output "public_ip" {
  value = azurerm_public_ip.runner.ip_address
}
output "vm_name" {
  value = azurerm_linux_virtual_machine.runner.name
}
output "nsg_name" {
  value = azurerm_network_security_group.runner.name
}

output "virtual_network_id" {
  description = "Resource ID of the project virtual network."
  value       = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  description = "Name of the project virtual network."
  value       = azurerm_virtual_network.this.name
}

output "app_service_integration_subnet_id" {
  description = "Resource ID of the subnet delegated to App Service."
  value       = azurerm_subnet.app_service_integration.id
}

output "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet reserved for Private Endpoints."
  value       = azurerm_subnet.private_endpoints.id
}

output "app_service_integration_nsg_id" {
  description = "Resource ID of the App Service integration subnet NSG."
  value       = azurerm_network_security_group.app_service_integration.id
}

output "private_dns_zone_ids" {
  description = "Private DNS zone resource IDs keyed by service name."
  value       = { for key, zone in azurerm_private_dns_zone.this : key => zone.id }
}

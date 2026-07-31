output "id" {
  description = "Azure resource ID of the container registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the container registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Hostname used to push and pull container images."
  value       = azurerm_container_registry.this.login_server
}

output "id" {
  description = "Azure resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "Name of the Linux Web App."
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default public hostname of the backend."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "https_url" {
  description = "Default HTTPS URL of the backend."
  value       = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "principal_id" {
  description = "Object ID of the Web App system-assigned managed identity."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "id" {
  description = "Azure resource ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "Private DNS-aware PostgreSQL server hostname."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Application database name."
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "administrator_login" {
  description = "PostgreSQL administrator login name."
  value       = var.administrator_login
}

output "password_secret_name" {
  description = "Key Vault secret containing the PostgreSQL password."
  value       = azurerm_key_vault_secret.administrator_password.name
}

output "private_endpoint_id" {
  description = "Azure resource ID of the PostgreSQL Private Endpoint."
  value       = azurerm_private_endpoint.this.id
}

output "id" {
  description = "Azure resource ID of the Azure Managed Redis instance."
  value       = azurerm_managed_redis.this.id
}

output "name" {
  description = "Name of the Azure Managed Redis instance."
  value       = azurerm_managed_redis.this.name
}

output "hostname" {
  description = "Private DNS-aware Azure Managed Redis hostname."
  value       = azurerm_managed_redis.this.hostname
}

output "port" {
  description = "Encrypted Redis port."
  value       = azurerm_managed_redis.this.default_database[0].port
}

output "access_key_secret_name" {
  description = "Key Vault secret containing the Redis access key."
  value       = azapi_resource.access_key.name
}

output "private_endpoint_id" {
  description = "Azure resource ID of the Redis Private Endpoint."
  value       = azurerm_private_endpoint.this.id
}

output "id" {
  description = "Azure resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Private DNS-aware URI of the Key Vault data plane."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint_id" {
  description = "Azure resource ID of the Key Vault Private Endpoint."
  value       = azurerm_private_endpoint.this.id
}

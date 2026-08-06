output "id" {
  description = "Resource ID of the GitHub Actions deployment identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID configured as the AZURE_CLIENT_ID GitHub variable."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "Service principal object ID of the deployment identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "tenant_id" {
  description = "Tenant ID configured as the AZURE_TENANT_ID GitHub variable."
  value       = azurerm_user_assigned_identity.this.tenant_id
}

output "federated_subject" {
  description = "GitHub OIDC subject trusted by Azure."
  value       = azurerm_federated_identity_credential.github_environment.subject
}

output "id" { value = azurerm_storage_account.this.id }
output "name" { value = azurerm_storage_account.this.name }
output "primary_blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }
output "container_name" { value = azurerm_storage_container.application_files.name }
output "private_endpoint_id" { value = azurerm_private_endpoint.blob.id }

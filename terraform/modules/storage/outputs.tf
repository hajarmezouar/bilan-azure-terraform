output "id" { value = azapi_resource.this.id }
output "name" { value = azapi_resource.this.name }
output "primary_blob_endpoint" { value = "https://${azapi_resource.this.name}.blob.core.windows.net/" }
output "container_name" { value = azapi_resource.application_files.name }
output "private_endpoint_id" { value = azurerm_private_endpoint.blob.id }

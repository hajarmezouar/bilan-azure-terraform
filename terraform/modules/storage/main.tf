resource "azapi_resource" "this" {
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  parent_id = var.resource_group_id
  name      = var.name
  location  = var.location

  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_${var.replication_type}"
    }
    properties = {
      accessTier                   = var.access_tier
      allowBlobPublicAccess        = false
      allowCrossTenantReplication  = false
      allowSharedKeyAccess         = false
      defaultToOAuthAuthentication = true
      isLocalUserEnabled           = false
      minimumTlsVersion            = "TLS1_2"
      publicNetworkAccess          = "Disabled"
      supportsHttpsTrafficOnly     = true
      networkAcls = {
        bypass              = "AzureServices"
        defaultAction       = "Deny"
        ipRules             = []
        virtualNetworkRules = []
      }
    }
  }

  tags = merge(var.tags, { component = "application-storage" })
}

resource "azapi_resource" "blob_service" {
  type      = "Microsoft.Storage/storageAccounts/blobServices@2023-05-01"
  parent_id = azapi_resource.this.id
  name      = "default"

  body = {
    properties = {
      changeFeed = {
        enabled = true
      }
      containerDeleteRetentionPolicy = {
        enabled = true
        days    = 7
      }
      deleteRetentionPolicy = {
        enabled = true
        days    = 7
      }
      isVersioningEnabled = true
    }
  }
}

resource "azapi_resource" "application_files" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01"
  parent_id = azapi_resource.blob_service.id
  name      = var.container_name

  body = {
    properties = {
      publicAccess = "None"
    }
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-${var.name}-blob"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}-blob"
    private_connection_resource_id = azapi_resource.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = merge(var.tags, { component = "storage-private-endpoint" })
}

resource "azurerm_role_assignment" "backend_blob_data_contributor" {
  scope                            = azapi_resource.this.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = var.backend_principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

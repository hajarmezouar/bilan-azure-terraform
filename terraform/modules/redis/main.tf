resource "azurerm_managed_redis" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name

  high_availability_enabled = false
  public_network_access     = "Disabled"

  default_database {
    access_keys_authentication_enabled = true
    client_protocol                    = "Encrypted"
    clustering_policy                  = "OSSCluster"
    eviction_policy                    = "AllKeysLRU"
  }

  tags = merge(var.tags, {
    component = "cache"
  })
}

resource "azurerm_private_endpoint" "this" {
  name                = "pe-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_managed_redis.this.id
    is_manual_connection           = false
    subresource_names              = ["redisEnterprise"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = merge(var.tags, {
    component = "redis-private-endpoint"
  })
}

resource "azapi_resource" "access_key" {
  type      = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  parent_id = var.key_vault_id
  name      = var.access_key_secret_name

  body = {
    properties = {
      contentType = "Azure Managed Redis access key"
    }
  }

  sensitive_body = {
    properties = {
      value = azurerm_managed_redis.this.default_database[0].primary_access_key
    }
  }

  sensitive_body_version = {
    "properties.value" = tostring(var.access_key_secret_version)
  }

  tags = merge(var.tags, {
    component = "redis-credential"
  })
}

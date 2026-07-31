ephemeral "random_password" "administrator" {
  length           = 32
  special          = true
  override_special = "_%@-"
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.postgresql_version
  sku_name            = var.sku_name

  administrator_login               = var.administrator_login
  administrator_password_wo         = ephemeral.random_password.administrator.result
  administrator_password_wo_version = 1

  storage_mb                    = var.storage_mb
  auto_grow_enabled             = true
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = false

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  lifecycle {
    # Azure selects a zone when none is requested. Preserve that placement
    # instead of proposing a meaningless zone -> null update after creation.
    ignore_changes = [zone]
  }

  tags = merge(var.tags, {
    component = "database"
  })
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_private_endpoint" "this" {
  name                = "pe-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = merge(var.tags, {
    component = "postgresql-private-endpoint"
  })
}

resource "azapi_resource" "administrator_password" {
  type      = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  parent_id = var.key_vault_id
  name      = var.password_secret_name

  body = {
    properties = {
      contentType = "PostgreSQL administrator password"
    }
  }

  sensitive_body = {
    properties = {
      value = ephemeral.random_password.administrator.result
    }
  }

  sensitive_body_version = {
    "properties.value" = "1"
  }

  tags = merge(var.tags, {
    component = "postgresql-credential"
  })
}

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

resource "azurerm_key_vault_secret" "administrator_password" {
  name             = var.password_secret_name
  key_vault_id     = var.key_vault_id
  value_wo         = ephemeral.random_password.administrator.result
  value_wo_version = 1
  content_type     = "PostgreSQL administrator password"

  tags = merge(var.tags, {
    component = "postgresql-credential"
  })
}

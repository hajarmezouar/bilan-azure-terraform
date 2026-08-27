resource "azurerm_resource_group" "project" {
  name     = var.resource_group_name
  location = var.expected_location
  tags     = var.common_tags
}

resource "azurerm_service_plan" "app" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.project.name
  location            = azurerm_resource_group.project.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
  tags                = var.common_tags
}

data "azurerm_client_config" "current" {}

module "network" {
  source = "../../modules/network"

  name_prefix                           = local.name_prefix
  resource_group_name                   = azurerm_resource_group.project.name
  location                              = azurerm_resource_group.project.location
  vnet_address_space                    = var.vnet_address_space
  app_service_integration_subnet_prefix = var.app_service_integration_subnet_prefix
  private_endpoint_subnet_prefix        = var.private_endpoint_subnet_prefix
  tags                                  = var.common_tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.project.name
  location            = azurerm_resource_group.project.location
  sku                 = var.container_registry_sku
  tags                = var.common_tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                       = var.key_vault_name
  resource_group_name        = azurerm_resource_group.project.name
  location                   = azurerm_resource_group.project.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["key_vault"]
  tags                       = var.common_tags
}

module "postgresql" {
  source = "../../modules/postgresql"

  name                       = var.postgresql_server_name
  resource_group_name        = azurerm_resource_group.project.name
  location                   = azurerm_resource_group.project.location
  postgresql_version         = var.postgresql_version
  sku_name                   = var.postgresql_sku_name
  storage_mb                 = var.postgresql_storage_mb
  database_name              = var.postgresql_database_name
  administrator_login        = var.postgresql_administrator_login
  key_vault_id               = module.key_vault.id
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["postgresql"]
  tags                       = var.common_tags
}

module "redis" {
  source = "../../modules/redis"

  name                       = var.redis_name
  resource_group_name        = azurerm_resource_group.project.name
  location                   = azurerm_resource_group.project.location
  sku_name                   = var.redis_sku_name
  key_vault_id               = module.key_vault.id
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["redis"]
  tags                       = var.common_tags
}

module "web_app" {
  source = "../../modules/web-app"

  name                            = var.backend_web_app_name
  resource_group_name             = azurerm_resource_group.project.name
  location                        = azurerm_resource_group.project.location
  service_plan_id                 = azurerm_service_plan.app.id
  virtual_network_subnet_id       = module.network.app_service_integration_subnet_id
  container_registry_id           = module.container_registry.id
  container_registry_login_server = module.container_registry.login_server
  key_vault_id                    = module.key_vault.id
  container_image_repository      = var.backend_container_image_repository
  container_image_tag             = var.backend_container_image_tag
  app_settings = {
    APP_CORS_ALLOWED_ORIGINS    = "https://${var.frontend_web_app_name}.azurewebsites.net"
    SPRING_DATASOURCE_URL       = "jdbc:postgresql://${module.postgresql.fqdn}:5432/${module.postgresql.database_name}?sslmode=require"
    SPRING_DATASOURCE_USERNAME  = module.postgresql.administrator_login
    SPRING_DATASOURCE_PASSWORD  = "@Microsoft.KeyVault(VaultName=${module.key_vault.name};SecretName=${module.postgresql.password_secret_name})"
    REDIS_HOSTNAME              = module.redis.hostname
    REDIS_PORT                  = tostring(module.redis.port)
    REDIS_PASSWORD              = "@Microsoft.KeyVault(VaultName=${module.key_vault.name};SecretName=${module.redis.access_key_secret_name})"
    REDIS_SSL_ENABLED           = "true"
    STORAGE_ACCOUNT_NAME        = var.storage_account_name
    STORAGE_CONTAINER_NAME      = var.storage_container_name
    AZURE_STORAGE_BLOB_ENDPOINT = "https://${var.storage_account_name}.blob.core.windows.net/"
  }
  tags = var.common_tags
}

module "web_app_frontend" {
  source = "../../modules/web-app"

  name                            = var.frontend_web_app_name
  resource_group_name             = azurerm_resource_group.project.name
  location                        = azurerm_resource_group.project.location
  service_plan_id                 = azurerm_service_plan.app.id
  virtual_network_subnet_id       = module.network.app_service_integration_subnet_id
  container_registry_id           = module.container_registry.id
  container_registry_login_server = module.container_registry.login_server
  container_image_repository      = var.frontend_container_image_repository
  container_image_tag             = var.frontend_container_image_tag
  container_port                  = 8080
  health_check_path               = "/"
  component                       = "frontend"
  spring_profiles_active          = null
  assign_key_vault_access         = false
  tags                            = var.common_tags
}

module "storage" {
  source = "../../modules/storage"

  name                       = var.storage_account_name
  resource_group_name        = azurerm_resource_group.project.name
  resource_group_id          = azurerm_resource_group.project.id
  location                   = azurerm_resource_group.project.location
  replication_type           = var.storage_replication_type
  access_tier                = var.storage_access_tier
  container_name             = var.storage_container_name
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["storage"]
  backend_principal_id       = module.web_app.principal_id
  tags                       = var.common_tags
}

module "github_actions_identity" {
  source = "../../modules/github-actions-identity"

  name                  = var.github_actions_identity_name
  resource_group_name   = azurerm_resource_group.project.name
  location              = azurerm_resource_group.project.location
  github_oidc_subject   = var.backend_github_oidc_subject
  github_environment    = var.backend_github_environment
  container_registry_id = module.container_registry.id
  web_app_id            = module.web_app.id
  tags                  = var.common_tags
}

module "github_actions_frontend" {
  source = "../../modules/github-actions-identity"

  name                  = var.frontend_github_actions_identity_name
  resource_group_name   = azurerm_resource_group.project.name
  location              = azurerm_resource_group.project.location
  github_oidc_subject   = var.frontend_github_oidc_subject
  github_environment    = "prod"
  container_registry_id = module.container_registry.id
  web_app_id            = module.web_app_frontend.id
  tags                  = var.common_tags
}

output "environment" {
  description = "Terraform environment name."
  value       = local.environment
}

output "name_prefix" {
  description = "Common prefix for resources created in later iterations."
  value       = local.name_prefix
}

output "resource_group" {
  description = "Existing project resource group verified by Terraform."
  value = {
    id       = data.azurerm_resource_group.project.id
    name     = data.azurerm_resource_group.project.name
    location = data.azurerm_resource_group.project.location
  }
}

output "shared_service_plan" {
  description = "Trainer-managed App Service Plan referenced by the backend."
  value = {
    id             = data.azurerm_service_plan.shared.id
    name           = data.azurerm_service_plan.shared.name
    resource_group = var.shared_service_plan_resource_group_name
    location       = data.azurerm_service_plan.shared.location
    os_type        = data.azurerm_service_plan.shared.os_type
    sku_name       = data.azurerm_service_plan.shared.sku_name
  }
}

output "network" {
  description = "Network resources used by the non-production application."
  value = {
    virtual_network_id                = module.network.virtual_network_id
    virtual_network_name              = module.network.virtual_network_name
    app_service_integration_subnet_id = module.network.app_service_integration_subnet_id
    app_service_integration_nsg_id    = module.network.app_service_integration_nsg_id
    private_endpoint_subnet_id        = module.network.private_endpoint_subnet_id
    private_dns_zone_ids              = module.network.private_dns_zone_ids
  }
}

output "container_registry" {
  description = "Container registry used for immutable backend images."
  value = {
    id           = module.container_registry.id
    name         = module.container_registry.name
    login_server = module.container_registry.login_server
  }
}

output "backend_web_app" {
  description = "Linux Web App hosting the containerized Spring Boot backend."
  value = {
    id               = module.web_app.id
    name             = module.web_app.name
    default_hostname = module.web_app.default_hostname
    https_url        = module.web_app.https_url
    principal_id     = module.web_app.principal_id
  }
}

output "key_vault" {
  description = "Private Key Vault used for application secrets."
  value = {
    id                  = module.key_vault.id
    name                = module.key_vault.name
    vault_uri           = module.key_vault.vault_uri
    private_endpoint_id = module.key_vault.private_endpoint_id
  }
}

output "postgresql" {
  description = "Private PostgreSQL Flexible Server used by the backend."
  value = {
    id                  = module.postgresql.id
    name                = module.postgresql.name
    fqdn                = module.postgresql.fqdn
    database_name       = module.postgresql.database_name
    administrator_login = module.postgresql.administrator_login
    private_endpoint_id = module.postgresql.private_endpoint_id
  }
}

output "redis" {
  description = "Private Azure Managed Redis instance used by the backend."
  value = {
    id                  = module.redis.id
    name                = module.redis.name
    hostname            = module.redis.hostname
    port                = module.redis.port
    private_endpoint_id = module.redis.private_endpoint_id
  }
}

output "storage" {
  value = {
    id                    = module.storage.id
    name                  = module.storage.name
    primary_blob_endpoint = module.storage.primary_blob_endpoint
    container_name        = module.storage.container_name
    private_endpoint_id   = module.storage.private_endpoint_id
  }
}

output "frontend_static_web_app" {
  value = {
    id                = module.static_web_app.id
    name              = module.static_web_app.name
    default_host_name = module.static_web_app.default_host_name
    https_url         = module.static_web_app.https_url
  }
}

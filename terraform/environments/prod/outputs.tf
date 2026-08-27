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
    id       = azurerm_resource_group.project.id
    name     = azurerm_resource_group.project.name
    location = azurerm_resource_group.project.location
  }
}

output "service_plan" {
  description = "Production App Service Plan created by Terraform."
  value = {
    id       = azurerm_service_plan.app.id
    name     = azurerm_service_plan.app.name
    location = azurerm_service_plan.app.location
    os_type  = azurerm_service_plan.app.os_type
    sku_name = azurerm_service_plan.app.sku_name
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

output "frontend_web_app" {
  value = {
    id               = module.web_app_frontend.id
    name             = module.web_app_frontend.name
    default_hostname = module.web_app_frontend.default_hostname
    https_url        = module.web_app_frontend.https_url
  }
}

output "backend_github_actions" {
  description = "Non-secret values required by the backend GitHub environment."
  value = {
    client_id           = module.github_actions_identity.client_id
    tenant_id           = module.github_actions_identity.tenant_id
    subscription_id     = nonsensitive(var.subscription_id)
    resource_group_name = azurerm_resource_group.project.name
    container_registry  = module.container_registry.name
    web_app_name        = module.web_app.name
    federated_subject   = module.github_actions_identity.federated_subject
  }
}

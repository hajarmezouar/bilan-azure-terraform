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

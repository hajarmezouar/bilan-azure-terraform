data "azurerm_resource_group" "project" {
  name = var.resource_group_name

  lifecycle {
    postcondition {
      condition     = self.location == var.expected_location
      error_message = "The existing resource group must be located in ${var.expected_location}."
    }
  }
}

data "azurerm_service_plan" "shared" {
  name                = var.shared_service_plan_name
  resource_group_name = var.shared_service_plan_resource_group_name

  lifecycle {
    postcondition {
      condition     = self.location == var.expected_location
      error_message = "The shared App Service Plan must be located in ${var.expected_location}."
    }

    postcondition {
      condition     = self.os_type == "Linux"
      error_message = "The shared App Service Plan must be a Linux plan."
    }
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix                           = local.name_prefix
  resource_group_name                   = data.azurerm_resource_group.project.name
  location                              = data.azurerm_resource_group.project.location
  vnet_address_space                    = var.vnet_address_space
  app_service_integration_subnet_prefix = var.app_service_integration_subnet_prefix
  private_endpoint_subnet_prefix        = var.private_endpoint_subnet_prefix
  tags                                  = var.common_tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  name                = var.container_registry_name
  resource_group_name = data.azurerm_resource_group.project.name
  location            = data.azurerm_resource_group.project.location
  sku                 = var.container_registry_sku
  tags                = var.common_tags
}

module "web_app" {
  source = "../../modules/web-app"

  name                            = var.backend_web_app_name
  resource_group_name             = data.azurerm_resource_group.project.name
  location                        = data.azurerm_resource_group.project.location
  service_plan_id                 = data.azurerm_service_plan.shared.id
  virtual_network_subnet_id       = module.network.app_service_integration_subnet_id
  container_registry_id           = module.container_registry.id
  container_registry_login_server = module.container_registry.login_server
  container_image_repository      = var.backend_container_image_repository
  container_image_tag             = var.backend_container_image_tag
  tags                            = var.common_tags
}

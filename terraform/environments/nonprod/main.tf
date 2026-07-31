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

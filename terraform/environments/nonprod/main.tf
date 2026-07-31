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

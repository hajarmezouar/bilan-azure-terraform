resource "azurerm_static_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_tier

  configuration_file_changes_enabled = true
  preview_environments_enabled       = true

  tags = merge(var.tags, { component = "frontend" })
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  https_only                                     = true
  public_network_access_enabled                  = true
  client_affinity_enabled                        = false
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  vnet_image_pull_enabled                        = false

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(var.app_settings, {
    SPRING_PROFILES_ACTIVE              = "prod"
    WEBSITES_CONTAINER_START_TIME_LIMIT = "600"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = tostring(var.container_port)
  })

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true
    ftps_state                              = "Disabled"
    health_check_eviction_time_in_min       = 5
    health_check_path                       = var.health_check_path
    http2_enabled                           = true
    minimum_tls_version                     = "1.2"
    scm_minimum_tls_version                 = "1.2"
    scm_use_main_ip_restriction             = true
    use_32_bit_worker                       = false
    vnet_route_all_enabled                  = true

    application_stack {
      docker_image_name   = "${var.container_image_repository}:${var.container_image_tag}"
      docker_registry_url = "https://${var.container_registry_login_server}"
    }
  }

  tags = merge(var.tags, {
    component = "backend"
  })

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name
    ]
  }
}

resource "azurerm_role_assignment" "container_registry_pull" {
  scope                            = var.container_registry_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_linux_web_app.this.identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                            = var.key_vault_id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_linux_web_app.this.identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

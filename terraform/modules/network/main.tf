resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]

  tags = merge(var.tags, {
    component = "network"
  })
}

resource "azurerm_network_security_group" "app_service_integration" {
  name                = "nsg-${var.name_prefix}-appservice-integration"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(var.tags, {
    component = "network-security"
  })
}

resource "azurerm_network_security_rule" "allow_private_outbound" {
  name                        = "AllowPrivateOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app_service_integration.name
}

resource "azurerm_network_security_rule" "allow_azure_https_outbound" {
  name                        = "AllowAzureHttpsOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app_service_integration.name
}

resource "azurerm_network_security_rule" "deny_internet_outbound" {
  name                        = "DenyInternetOutbound"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app_service_integration.name
}

resource "azurerm_subnet" "app_service_integration" {
  name                              = "snet-appservice-integration"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [var.app_service_integration_subnet_prefix]
  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Enabled"

  delegation {
    name = "app-service-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "app_service_integration" {
  subnet_id                 = azurerm_subnet.app_service_integration.id
  network_security_group_id = azurerm_network_security_group.app_service_integration.id
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-private-endpoints"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [var.private_endpoint_subnet_prefix]
  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zones

  name                = each.value
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    component = "private-dns"
    service   = each.key
  })
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = azurerm_private_dns_zone.this

  name                  = "link-${var.name_prefix}-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = merge(var.tags, {
    component = "private-dns-link"
    service   = each.key
  })
}

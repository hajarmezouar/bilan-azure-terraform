locals {
  name = "quiz-ci-runner"
  tags = { managed_by = "terraform", project = "azure-quiz", purpose = "self-hosted-runner", environment = "training" }
}

# Reuse the assigned training resource group; never destroy it with this state.
data "azurerm_resource_group" "runner" {
  name = var.resource_group_name
}
resource "azurerm_virtual_network" "runner" {
  name                = "vnet-${local.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.runner.name
  address_space       = ["10.80.0.0/16"]
  tags                = local.tags
}
resource "azurerm_subnet" "runner" {
  name                 = "runner"
  resource_group_name  = data.azurerm_resource_group.runner.name
  virtual_network_name = azurerm_virtual_network.runner.name
  address_prefixes     = ["10.80.1.0/24"]
}
resource "azurerm_network_security_group" "runner" {
  name                = "nsg-${local.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.runner.name
  tags                = local.tags
}
# Standalone rules allow CI to own one temporary rule without inline-rule drift.
resource "azurerm_network_security_rule" "candidate" {
  name                        = "ssh-candidate"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.candidate_cidr
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.runner.name
  network_security_group_name = azurerm_network_security_group.runner.name
}
resource "azurerm_network_security_rule" "deny_inbound" {
  name                        = "deny-other-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.runner.name
  network_security_group_name = azurerm_network_security_group.runner.name
}
resource "azurerm_public_ip" "runner" {
  name                = "pip-${local.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.runner.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}
resource "azurerm_network_interface" "runner" {
  name                = "nic-${local.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.runner.name
  tags                = local.tags
  ip_configuration {
    name                          = "runner"
    subnet_id                     = azurerm_subnet.runner.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.runner.id
  }
}
resource "azurerm_network_interface_security_group_association" "runner" {
  network_interface_id      = azurerm_network_interface.runner.id
  network_security_group_id = azurerm_network_security_group.runner.id
}
resource "azurerm_linux_virtual_machine" "runner" {
  name                            = local.name
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.runner.name
  size                            = var.vm_size
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.runner.id]
  secure_boot_enabled             = true
  vtpm_enabled                    = true
  tags                            = local.tags
  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 64
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  boot_diagnostics {}
  depends_on = [azurerm_network_interface_security_group_association.runner, azurerm_network_security_rule.deny_inbound]
}

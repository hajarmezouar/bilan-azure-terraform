terraform {
  required_version = ">= 1.11.0"
  cloud {
    organization = "hmezouar-azure-quiz"
    workspaces {
      name = "azure-quiz-runner-bootstrap"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}
variable "subscription_id" {
  type = string
}
variable "resource_group_name" {
  type    = string
  default = "hmezouarRG"
}
variable "state_storage_account_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.state_storage_account_name))
    error_message = "A globally unique storage name must contain 3–24 lowercase letters or digits."
  }
}
data "azurerm_resource_group" "state" {
  name = var.resource_group_name
}
data "azurerm_client_config" "current" {}

# Bootstrap state stays in HCP so the Blob account never stores its own state.
# The GitHub-hosted bootstrap requires the public endpoint; shared keys and anonymous access remain disabled.\n#trivy:ignore:AVD-AZU-0012
resource "azurerm_storage_account" "state" {
  name                            = var.state_storage_account_name
  resource_group_name             = data.azurerm_resource_group.state.name
  location                        = data.azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  tags                            = { managed_by = "terraform", project = "azure-quiz", purpose = "runner-state" }
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_role_assignment" "state" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

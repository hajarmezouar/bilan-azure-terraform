variable "name_prefix" {
  description = "Prefix used to name the network resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name_prefix)) > 0
    error_message = "The network name prefix must not be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group in which network resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for regional network resources."
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR address space assigned to the virtual network."
  type        = string

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "The virtual network address space must be a valid CIDR block."
  }
}

variable "app_service_integration_subnet_prefix" {
  description = "CIDR prefix of the subnet delegated to App Service."
  type        = string

  validation {
    condition     = can(cidrhost(var.app_service_integration_subnet_prefix, 0))
    error_message = "The App Service integration subnet prefix must be a valid CIDR block."
  }
}

variable "private_endpoint_subnet_prefix" {
  description = "CIDR prefix reserved for Private Endpoints."
  type        = string

  validation {
    condition     = can(cidrhost(var.private_endpoint_subnet_prefix, 0))
    error_message = "The Private Endpoint subnet prefix must be a valid CIDR block."
  }
}

variable "private_dns_zones" {
  description = "Private DNS zones linked to the virtual network, keyed by service name."
  type        = map(string)

  default = {
    key_vault  = "privatelink.vaultcore.azure.net"
    postgresql = "privatelink.postgres.database.azure.com"
    redis      = "privatelink.redis.azure.net"
    storage    = "privatelink.blob.core.windows.net"
  }

  validation {
    condition     = length(var.private_dns_zones) > 0 && alltrue([for zone in values(var.private_dns_zones) : length(trimspace(zone)) > 0])
    error_message = "At least one non-empty private DNS zone must be provided."
  }
}

variable "tags" {
  description = "Tags applied to resources that support tags."
  type        = map(string)
  default     = {}
}

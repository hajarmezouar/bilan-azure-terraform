variable "name" {
  description = "Globally unique Azure Key Vault name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "The Key Vault name must contain 3 to 24 letters, numbers or hyphens, start with a letter and end with a letter or number."
  }
}

variable "resource_group_name" {
  description = "Resource group in which the Key Vault is created."
  type        = string
}

variable "location" {
  description = "Azure region in which the Key Vault and Private Endpoint are created."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used by Key Vault."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet reserved for Private Endpoints."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the privatelink.vaultcore.azure.net private DNS zone."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Key Vault and Private Endpoint."
  type        = map(string)
  default     = {}
}

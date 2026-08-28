variable "name" {
  description = "Name of the Azure Managed Redis instance."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which Redis resources are created."
  type        = string
}

variable "location" {
  description = "Azure region in which Redis resources are created."
  type        = string
}

variable "sku_name" {
  description = "Azure Managed Redis SKU."
  type        = string
  default     = "Balanced_B0"
}

variable "access_key_secret_name" {
  description = "Key Vault secret name used for the Redis primary access key."
  type        = string
  default     = "redis-access-key"
}

variable "access_key_secret_version" {
  description = "Version used to republish the current Redis access key to Key Vault after recovery or rotation."
  type        = number
  default     = 3

  validation {
    condition     = var.access_key_secret_version >= 1 && floor(var.access_key_secret_version) == var.access_key_secret_version
    error_message = "The Redis access-key secret version must be a positive integer."
  }
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault receiving the Redis access key."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet reserved for Private Endpoints."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the Azure Managed Redis Private Link DNS zone."
  type        = string
}

variable "tags" {
  description = "Tags applied to Redis resources."
  type        = map(string)
  default     = {}
}

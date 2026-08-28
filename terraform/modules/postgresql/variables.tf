variable "name" {
  description = "Globally unique PostgreSQL Flexible Server name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which PostgreSQL resources are created."
  type        = string
}

variable "location" {
  description = "Azure region in which PostgreSQL resources are created."
  type        = string
}

variable "postgresql_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server compute SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Allocated PostgreSQL storage in MiB."
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Number of days for which PostgreSQL backups are retained."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "PostgreSQL backup retention must be between 7 and 35 days."
  }
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "quizz"
}

variable "administrator_login" {
  description = "Non-sensitive PostgreSQL administrator login name."
  type        = string
  default     = "quizadmin"
}

variable "administrator_password_version" {
  description = "Rotation version shared by PostgreSQL and its Key Vault secret. Increment to rotate both atomically."
  type        = number
  default     = 3

  validation {
    condition     = var.administrator_password_version >= 1 && floor(var.administrator_password_version) == var.administrator_password_version
    error_message = "The PostgreSQL administrator password version must be a positive integer."
  }
}

variable "password_secret_name" {
  description = "Key Vault secret name used for the PostgreSQL administrator password."
  type        = string
  default     = "postgresql-administrator-password"
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault receiving the write-only password."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet reserved for Private Endpoints."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL Private Link DNS zone."
  type        = string
}

variable "tags" {
  description = "Tags applied to PostgreSQL resources."
  type        = map(string)
  default     = {}
}

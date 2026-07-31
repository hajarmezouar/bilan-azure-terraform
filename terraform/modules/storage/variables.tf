variable "name" {
  description = "Globally unique name of the application Storage Account."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The Storage Account name must contain 3 to 24 lowercase letters or numbers."
  }
}

variable "resource_group_name" { type = string }
variable "resource_group_id" { type = string }
variable "location" { type = string }

variable "replication_type" {
  description = "Storage replication type without the Standard tier prefix."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.replication_type)
    error_message = "The replication type must be LRS, ZRS, GRS or GZRS."
  }
}

variable "access_tier" {
  description = "Default Blob Storage access tier."
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "The access tier must be Hot or Cool."
  }
}

variable "container_name" {
  description = "Private blob container used for application files."
  type        = string
  default     = "application-files"
  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$", var.container_name))
    error_message = "The container name must be 3 to 63 lowercase letters, numbers or single hyphens."
  }
}

variable "private_endpoint_subnet_id" { type = string }
variable "private_dns_zone_id" { type = string }
variable "backend_principal_id" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

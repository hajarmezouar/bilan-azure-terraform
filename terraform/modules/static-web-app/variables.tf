variable "name" {
  description = "Globally unique name of the Azure Static Web App."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,60}$", var.name))
    error_message = "The Static Web App name must contain 2 to 60 letters, numbers or hyphens."
  }
}

variable "resource_group_name" { type = string }

variable "location" {
  type    = string
  default = "westeurope"
}

variable "sku_tier" {
  type    = string
  default = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "The Static Web Apps SKU must be Free or Standard."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

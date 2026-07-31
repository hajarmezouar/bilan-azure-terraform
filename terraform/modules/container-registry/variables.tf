variable "name" {
  description = "Globally unique Azure Container Registry name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "The registry name must contain 5 to 50 alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "Resource group in which the registry is created."
  type        = string
}

variable "location" {
  description = "Azure region in which the registry is created."
  type        = string
}

variable "sku" {
  description = "Azure Container Registry service tier."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The registry SKU must be Basic, Standard or Premium."
  }
}

variable "tags" {
  description = "Tags applied to the registry."
  type        = map(string)
  default     = {}
}

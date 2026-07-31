variable "name" {
  description = "Globally unique name of the Linux Web App."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,60}$", var.name))
    error_message = "The Web App name must contain 2 to 60 letters, numbers or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group in which the Web App is created."
  type        = string
}

variable "location" {
  description = "Azure region in which the Web App is created."
  type        = string
}

variable "service_plan_id" {
  description = "Resource ID of the existing Linux App Service Plan."
  type        = string
}

variable "virtual_network_subnet_id" {
  description = "Resource ID of the subnet delegated to App Service."
  type        = string
}

variable "container_registry_id" {
  description = "Resource ID of the Azure Container Registry."
  type        = string
}

variable "container_registry_login_server" {
  description = "Login server hostname of the Azure Container Registry."
  type        = string
}

variable "container_image_repository" {
  description = "Container image repository inside the registry."
  type        = string
  default     = "azure-quiz-backend"
}

variable "container_image_tag" {
  description = "Immutable tag or digest selected for the backend container image."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "TCP port exposed by the backend container."
  type        = number
  default     = 8080

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "The container port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Unauthenticated HTTP endpoint used by App Service health checks."
  type        = string
  default     = "/actuator/health"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "The health check path must start with a forward slash."
  }
}

variable "app_settings" {
  description = "Additional non-sensitive application settings. Sensitive values must use Key Vault references."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to the Web App."
  type        = map(string)
  default     = {}
}

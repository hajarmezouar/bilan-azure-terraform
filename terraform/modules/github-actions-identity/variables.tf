variable "name" {
  description = "Name of the user-assigned identity used by GitHub Actions."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the deployment identity."
  type        = string
}

variable "location" {
  description = "Azure region of the deployment identity."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/name format."
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "The GitHub repository must use the owner/name format."
  }
}

variable "github_environment" {
  description = "Protected GitHub environment allowed to request Azure tokens."
  type        = string
  default     = "nonprod"
}

variable "container_registry_id" {
  description = "Resource ID of the registry receiving backend images."
  type        = string
}

variable "web_app_id" {
  description = "Resource ID of the Web App receiving backend deployments."
  type        = string
}

variable "tags" {
  description = "Tags applied to the deployment identity."
  type        = map(string)
  default     = {}
}

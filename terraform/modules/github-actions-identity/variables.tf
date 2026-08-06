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

variable "github_oidc_subject" {
  description = "Exact subject claim emitted by GitHub Actions for the trusted environment."
  type        = string

  validation {
    condition     = can(regex("^repo:[^/]+/[^:]+:environment:[^:]+$", var.github_oidc_subject))
    error_message = "The GitHub OIDC subject must use repo:<owner>/<repository>:environment:<environment>."
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

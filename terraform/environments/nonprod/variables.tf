variable "subscription_id" {
  description = "Azure subscription containing the non-production environment."
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Existing resource group assigned to the project."
  type        = string
  default     = "hmezouarRG"
}

variable "expected_location" {
  description = "Azure region approved for the project."
  type        = string
  default     = "francecentral"
}

variable "shared_service_plan_name" {
  description = "Trainer-managed Linux App Service Plan used by the backend."
  type        = string
  default     = "plan-npr-prf2026"
}

variable "shared_service_plan_resource_group_name" {
  description = "Resource group containing the trainer-managed App Service Plan."
  type        = string
  default     = "rg-shared-prf2026"
}

variable "common_tags" {
  description = "Tags applied to resources managed by this project."
  type        = map(string)

  default = {
    owner       = "hmezouar"
    environment = "nonprod"
    project     = "azure-quiz"
    managed-by  = "terraform"
  }
}

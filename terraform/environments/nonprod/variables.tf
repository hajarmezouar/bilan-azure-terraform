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

variable "vnet_address_space" {
  description = "CIDR address space assigned to the non-production virtual network."
  type        = string
  default     = "10.50.0.0/16"
}

variable "app_service_integration_subnet_prefix" {
  description = "CIDR prefix of the subnet delegated to App Service."
  type        = string
  default     = "10.50.1.0/24"
}

variable "private_endpoint_subnet_prefix" {
  description = "CIDR prefix reserved for Private Endpoints."
  type        = string
  default     = "10.50.2.0/24"
}

variable "container_registry_name" {
  description = "Globally unique name of the non-production container registry."
  type        = string
  default     = "acrhmezouarquiznonprod"
}

variable "container_registry_sku" {
  description = "Cost tier of the non-production container registry."
  type        = string
  default     = "Basic"
}

variable "backend_web_app_name" {
  description = "Globally unique name of the non-production backend Web App."
  type        = string
  default     = "app-azure-quiz-backend-nonprod"
}

variable "backend_container_image_repository" {
  description = "ACR repository containing the Spring Boot backend image."
  type        = string
  default     = "azure-quiz-backend"
}

variable "backend_container_image_tag" {
  description = "Container image tag deployed to the non-production backend."
  type        = string
  default     = "latest"
}

variable "key_vault_name" {
  description = "Globally unique name of the non-production Key Vault."
  type        = string
  default     = "kv-hmezouar-quiz-np"
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

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

variable "postgresql_server_name" {
  description = "Globally unique PostgreSQL Flexible Server name."
  type        = string
  default     = "psql-hmezouar-quiz-np"
}

variable "postgresql_version" {
  description = "PostgreSQL major version used by the application."
  type        = string
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "Cost-optimized PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage allocation in MiB."
  type        = number
  default     = 32768
}

variable "postgresql_database_name" {
  description = "PostgreSQL database used by the backend."
  type        = string
  default     = "quizz"
}

variable "postgresql_administrator_login" {
  description = "Non-sensitive PostgreSQL administrator login."
  type        = string
  default     = "quizadmin"
}

variable "redis_name" {
  description = "Name of the non-production Azure Managed Redis instance."
  type        = string
  default     = "redis-hmezouar-quiz-np"
}

variable "redis_sku_name" {
  description = "Cost-optimized Azure Managed Redis SKU."
  type        = string
  default     = "Balanced_B0"
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

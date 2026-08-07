terraform {
  required_version = ">= 1.11.0"

  cloud {
    organization = "hmezouar-azure-quiz"

    workspaces {
      name = "azure-quiz-nonprod"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

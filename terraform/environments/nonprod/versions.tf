terraform {
  required_version = ">= 1.7.0"

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
  }
}

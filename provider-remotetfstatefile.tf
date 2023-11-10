terraform {
    backend "local" {
    path = "C:/Users/SivaNagaRajuVeeranki/Downloads/before kyndryl os installation/courses/terraform/terraform bigginers/Day-3/mystatefile"
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.62.1"
    }
  }
}

provider "azurerm" {
  features {}
  client_id                   = var.client_id
  client_secret               = var.client_secret
  tenant_id                   = var.tenant_id
  subscription_id             = var.subscription_id
}
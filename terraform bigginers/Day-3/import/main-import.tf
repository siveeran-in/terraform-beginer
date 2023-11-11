terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.62.1"
    }
  }
}

provider "azurerm" {
  features {}
  client_id                   = "0c092783-d289-4522-adc7-fceda9876c9b"
  client_secret               = "pxT8Q~AZZhvINCLJhD2T8.PTK9ymnKNoYu8LvcEZ"
  tenant_id                   = "6a69f483-9714-4eb3-aedc-ef87d3497470"
  subscription_id             = "00144ea6-e433-44c4-bbd2-6d75d72bc05d"
}

resource "azurerm_linux_virtual_machine" "sample" {
}
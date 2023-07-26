terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  # The storage account needs to be created before using the backend
  backend "azurerm" {
    resource_group_name  = "GCT"
    storage_account_name = "gcttfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "string" {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource "azurerm_static_site" "gct-static-webapp" {
  name                = "gct${random_string.string.result}"
  resource_group_name = var.resource_group_name
  location            = "westeurope"
  sku_size            = "Free"
  sku_tier            = "Free"

  tags = {
    environment = var.environment
  }
}

data "azurerm_client_config" "current" {}

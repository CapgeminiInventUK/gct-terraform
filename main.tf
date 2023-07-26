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

resource "azurerm_key_vault" "gct-keyvault" {
  name                        = "gct-keyvault-${var.environment}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "List",
      "Purge"
    ]
  }

  tags = {
    environment = var.environment
  }
}

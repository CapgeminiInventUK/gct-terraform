terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
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
  sku_size            = "Standard"
  sku_tier            = "Standard"

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



resource "azurerm_storage_account" "gct-storage-account" {
  name                     = "gctstorage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_service_plan" "gct-service-plan" {
  name                = "gctserviceplan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_linux_function_app" "gct-function-app" {
  name                = "gctfunctionappalextracker"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.gct-storage-account.name
  storage_account_access_key = azurerm_storage_account.gct-storage-account.primary_access_key
  service_plan_id            = azurerm_service_plan.gct-service-plan.id

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    COSMOS_DB_CONNECTION_STRING = azurerm_cosmosdb_account.gct.primary_sql_connection_string
  }

  tags = {
    environment = var.environment
  }
}

resource "azapi_resource" "link-fe-to-be" {
  type      = "Microsoft.Web/staticSites/userProvidedFunctionApps@2022-03-01"
  name      = "link-fe-to-be"
  parent_id = azurerm_static_site.gct-static-webapp.id
  body = jsonencode({
    properties = {
      functionAppRegion     = var.location
      functionAppResourceId = azurerm_linux_function_app.gct-function-app.id
    }
  })
}


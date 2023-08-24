resource "azurerm_cosmosdb_account" "gct" {
  name                      = "gct-cosmos-db"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  capabilities {
    name = "EnableServerless"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_cosmosdb_sql_database" "gct" {
  name                = "gct-nosql-database"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.gct.name
}

resource "azurerm_cosmosdb_sql_container" "competencies" {
  name                = "competencies"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.gct.name
  database_name       = azurerm_cosmosdb_sql_database.gct.name
  partition_key_path  = "/id"
}

resource "azurerm_cosmosdb_sql_container" "users" {
  name                = "users"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.gct.name
  database_name       = azurerm_cosmosdb_sql_database.gct.name
  partition_key_path  = "/id"
}
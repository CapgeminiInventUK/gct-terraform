resource "azurerm_key_vault_secret" "gct_web_api_token_secret" {
  name         = "gct-web-api-token-secret"
  value        = azurerm_static_site.gct-static-webapp.api_key
  key_vault_id = azurerm_key_vault.gct-keyvault.id

  tags = {
    environment = var.environment
  }
}

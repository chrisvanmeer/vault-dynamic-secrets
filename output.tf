output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "client_id" {
  value = data.azuread_service_principal.vault.application_id
}

output "client_secret" {
  value     = azuread_application_password.client_secret.value
  sensitive = true
}

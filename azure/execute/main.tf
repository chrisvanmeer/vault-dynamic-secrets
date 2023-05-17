terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.53.0"
    }
  }
}

# Configure the Azure Providers
provider "azuread" {
}
provider "azurerm" {
  features {}
  subscription_id = "33ad2909-a454-47be-b158-f3d83c373752"
}

# Retrieve current client information
data "azuread_client_config" "current" {}

# Retrieve subscription ID
data "azurerm_subscription" "current" {}

# Retrieve app and SP details
data "azuread_application" "vault" {
  display_name = "Vault"
}
data "azuread_service_principal" "vault" {
  display_name = "Vault"
}

# Create a client secret
resource "azuread_application_password" "client_secret" {
  application_object_id = data.azuread_application.vault.id
}

# Ensure resource group
resource "azurerm_resource_group" "rg" {
  name     = "vault-fundamentals"
  location = "West Europe"
}

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
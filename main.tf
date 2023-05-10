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
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
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

# Gernerate random UUID
resource "random_uuid" "random_uuid" {}

# Ensure app registration
resource "azuread_application" "app" {
  display_name = "Vault Fundamentals"
  owners       = [data.azuread_client_config.current.object_id]

  app_role {
    allowed_member_types = ["Application"]
    description          = "Reader role enabling app to read subscription details"
    display_name         = "Reader"
    enabled              = true
    id                   = random_uuid.random_uuid.result
    value                = "Read.All"
  }
}

# Create a client secret
resource "azuread_application_password" "client_secret" {
  application_object_id = azuread_application.app.object_id
}

# Create a service principle for the application
resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.app.application_id
}

# Assign the Contributor role to the application service principle
resource "azurerm_role_assignment" "contributor_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.service_principal.object_id
}

# Ensure resource group
resource "azurerm_resource_group" "rg_development" {
  name     = "Development"
  location = "West Europe"
}

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

# Retrieve App ID's
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# Ensure app registration
resource "azuread_application" "app" {
  display_name = "Vault"
  owners       = [data.azuread_client_config.current.object_id]
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
      type = "Role"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
      type = "Role"
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

# Create a service principle for the application
resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.app.application_id
  lifecycle {
    prevent_destroy = true
  }
}

# Assign the Contributor role to the application service principle
resource "azurerm_role_assignment" "contributor_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.service_principal.object_id
  lifecycle {
    prevent_destroy = true
  }
}

# Output when finished
output "Finished" {
  value = "You now need to have an admin grant a consent for ${azuread_application.app.display_name}"
}

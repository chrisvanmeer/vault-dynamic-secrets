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
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
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

    # Delegated
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Application.Read.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Application.ReadWrite.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.AccessAsUser.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.Read.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.ReadWrite.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Group.Read.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Group.ReadWrite.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["GroupMember.Read.All"]
    #   type = "Scope"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["GroupMember.ReadWrite.All"]
    #   type = "Scope"
    # }

    # Application
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["Application.Read.All"]
    #   type = "Role"
    # }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
      type = "Role"
    }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"]
    #   type = "Role"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
    #   type = "Role"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["Directory.ReadWrite.All"]
    #   type = "Role"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["Group.Read.All"]
    #   type = "Role"
    # }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
      type = "Role"
    }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["GroupMember.Read.All"]
    #   type = "Role"
    # }
    # resource_access {
    #   id   = data.azuread_service_principal.msgraph.app_role_ids["GroupMember.ReadWrite.All"]
    #   type = "Role"
    # }
  }
}

# Create a service principle for the application
resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.app.application_id
}

# Create a client secret
resource "azuread_application_password" "client_secret" {
  application_object_id = azuread_application.app.object_id
}

# Assign the Contributor role to the application service principle
resource "azurerm_role_assignment" "contributor_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.service_principal.object_id
}

# Ensure resource group
resource "azurerm_resource_group" "rg_vault-fundamentals" {
  name     = "vault-fundamentals"
  location = "West Europe"
}


# Workaround
# resource "null_resource" "aad_admin_consent" {
#   triggers = merge(
#     [for app in azuread_application.app.required_resource_access :
#       { for role in app.resource_access :
#         join("_", [app.resource_app_id, role.id]) => role.type
#       }
#     ]...
#   )

#   provisioner "local-exec" {
#     command = "sleep 30 && az ad app permission admin-consent --id ${azuread_application.app.application_id}"
#   }
# }

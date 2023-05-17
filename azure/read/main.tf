terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.2"
    }
  }
}

provider "vault" {}

data "vault_azure_access_credentials" "creds" {
  backend        = "azure"
  role           = "vault-fundamentals"
  validate_creds = true
}

output "client_id" {
  value = data.vault_azure_access_credentials.creds.client_id
}

output "client_secret" {
  sensitive = true
  value     = data.vault_azure_access_credentials.creds.client_secret
}

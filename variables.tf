variable "azure_tenant_id" {
  description = "The Tenant ID which will be used to register the app"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "azure_subscription_id" {
  description = "The subscription which will be used to register the app"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

terraform {
  #required_version = "1.5.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.62.0" # Optional but recommended in production
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=2.7.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id     = "50cf0a46-a844-41a9-a708-8a9ac2f0eecc"
  tenant_id           = "c5976b7f-e326-4d2b-9c44-183c29371942"
  storage_use_azuread = true
}
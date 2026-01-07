/*
resource "azapi_resource" "symbolicname" {
  type = "Microsoft.Search/searchServices@2025-05-01"
  name = "testsearch0101"
  parent_id = azurerm_resource_group.main.id
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }
  location = azurerm_resource_group.main.location

  body = {
    properties = {
      hostingMode = "default"
      dataExfiltrationProtections = ["BlockAll"]
      disableLocalAuth = true
      encryptionWithCmk = {
        enforcement = "Enabled"
      }
      partitionCount = 1
      publicNetworkAccess = "disabled"
      replicaCount = 2
      semanticSearch = "standard"
    }
    sku = {
      name = "standard"
    }
  }
}

*/
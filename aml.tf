
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.main.location
  name                = "aml-test-uai2"
  resource_group_name = azurerm_resource_group.main.name
}
# resource "azurerm_log_analytics_workspace" "this" {
#   name                = "workspace-test2"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }

# resource "azurerm_application_insights" "this" {
#   name                = "tf-test-appinsights2"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   workspace_id        = azurerm_log_analytics_workspace.this.id
#   application_type    = "web"
# }

# resource "azurerm_storage_account" "this" {
#   name                     = "machinelearning32"
#   resource_group_name      = azurerm_resource_group.main.name
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   #shared_access_key_enabled  = false
# }

/*
# Create Key Vault
resource "azurerm_key_vault" "aml_kv" {
  name                          = "${var.resource_group_name}-kv6"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = true
  enable_rbac_authorization     = true
}

resource "azurerm_role_assignment" "example" {
  scope                = resource.azurerm_resource_group.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  #principal_id         = azapi_resource.document_intelligence.identity[1].principal_id
  principal_id = azurerm_user_assigned_identity.this.principal_id
}


resource "azurerm_key_vault_key" "cmk" {
  name         = "aml-cmk14"
  key_vault_id = azurerm_key_vault.aml_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
}

*/
/*

#--------------------------------
# manages Azure Ai Services
#--------------------------------
resource "azurerm_role_assignment" "this" {
  scope                = resource.azurerm_resource_group.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azapi_resource.aml.identity[0].principal_id
  #principal_id = azurerm_user_assigned_identity.this.principal_id
}

# resource "azurerm_role_assignment" "this2" {
#   scope                = resource.azurerm_resource_group.main.id
#   role_definition_name = "Key Vault Crypto Service Encryption User"
#   #principal_id         = azapi_resource.aml.identity[0].principal_id
#   principal_id = azurerm_user_assigned_identity.this.principal_id
# }


/*
resource "azapi_resource" "aml" {
  type = "Microsoft.MachineLearningServices/workspaces@2025-09-01"
  name = var.aml_name
  parent_id = azurerm_resource_group.main.id
  identity {
    type = "SystemAssigned"
  }
  location = "Central India"
  schema_validation_enabled = false
  body = {
    #kind = "string"
    properties = {
      allowPublicAccessWhenBehindVnet = false
      applicationInsights = azurerm_application_insights.this.id
      # associatedWorkspaces = [
      #   "string"
      # ]
      #containerRegistry = "string"
      #description = "string"
      #discoveryUrl = "string"
      enableDataIsolation = true
      enableServiceSideCMKEncryption = true
      encryption = {
        keyVaultProperties = {
          keyIdentifier = azurerm_key_vault_key.cmk.id
          keyVaultArmId = azurerm_key_vault.aml_kv.id
        }
        status = "Enabled"
      }
      # featureStoreSettings = {
      #   computeRuntime = {
      #     sparkRuntimeVersion = "string"
      #   }
      #   offlineStoreConnectionName = "string"
      #   onlineStoreConnectionName = "string"
      # }
      #friendlyName = "string"
      hbiWorkspace = false
      #hubResourceId = "string"
      imageBuildCompute = "string"
      keyVault = azurerm_key_vault.aml_kv.id
      managedNetwork = {
        enableFirewallLog = false
        enableNetworkMonitor = false
        enbleprivateendpointconnections = true
        #firewallPublicIpAddress = "string"
        firewallSku = "Standard"
        isolationMode = "Disabled"
        managedNetworkKind = "V2"
        # outboundRules = {
        #   {customized property} = {
        #     category = "string"
        #     status = "string"
        #     type = "string"
        #     // For remaining properties, see OutboundRule objects
        #   }
        # }
        status = {
          sparkReady = true
          status = "Active"
        }
      }
  # primaryUserAssignedIdentity removed due to UAI not supported for CMK
      provisionNetworkNow = true
      publicNetworkAccess = "Disabled"
      # serverlessComputeSettings = {
      #   serverlessComputeCustomSubnet = "string"
      #   serverlessComputeNoPublicIP = bool
      # }
      # serviceManagedResourcesSettings = {
      #   cosmosDb = {
      #     collectionsThroughput = int
      #   }
      # }
      # sharedPrivateLinkResources = [
      #   {
      #     name = "string"
      #     properties = {
      #       groupId = "string"
      #       privateLinkResourceId = "string"
      #       requestMessage = "string"
      #       status = "string"
      #     }
      #   }
      # ]
      storageAccount = azurerm_storage_account.this.id
      systemDatastoresAuthMode = "Identity"
      v1LegacyMode = false
      # workspaceHubConfig = {
      #   additionalWorkspaceStorageAccounts = [
      #     "string"
      #   ]
      #   defaultWorkspaceResourceGroup = "string"
      # }
    }
    sku = {
      #capacity = int
      #family = "string"
      name = "Basic"
      #size = "string"
      tier = "Basic"
    }
  }
}
*/
/*

resource "azapi_resource" "aml" {
  type      = "Microsoft.MachineLearningServices/workspaces@2025-07-01-preview"
  parent_id = azurerm_resource_group.main.id
  name      = var.aml_name
  location  = var.location
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
  body = {
    properties = {
      applicationInsights = azurerm_application_insights.this.id
      keyVault            = azurerm_key_vault.aml_kv.id
      publicNetworkAccess = "Disabled"
      storageAccount      = azurerm_storage_account.this.id
      v1LegacyMode        = false
      enableServiceSideCMKEncryption = true
      encryption = {
        identity = {
          userAssignedIdentity = azurerm_user_assigned_identity.this.id
        }
        keyVaultProperties = {
          keyIdentifier = azurerm_key_vault_key.cmk.id
          keyVaultArmId = azurerm_key_vault.aml_kv.id
        }
        status = "Enabled"
      }
      systemDatastoresAuthMode = "Identity"
      v1LegacyMode = false
      # managedNetwork = {
      #   enableFirewallLog = false
      #   enableNetworkMonitor = false
      #   enbleprivateendpointconnections = true
      #   #firewallPublicIpAddress = "string"
      #   primaryUserAssignedIdentity: azurerm_user_assigned_identity.this.id
      #   firewallSku = "Standard"
      #   isolationMode = "Disabled"
      #   managedNetworkKind = "V2"
      #   # outboundRules = {
      #   #   {customized property} = {
      #   #     category = "string"
      #   #     status = "string"
      #   #     type = "string"
      #   #     // For remaining properties, see OutboundRule objects
      #   #   }
      #   # }
      #   status = {
      #     sparkReady = true
      #     status = "Active"
      #   }
      # }
    }
    sku = {
      name = "Basic"
      tier = "Basic"
    }
  }
  ignore_casing             = true
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

*/

/*

resource "azurerm_search_service" "example" {
  name                = "testcmekenable"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "standard"

  local_authentication_enabled = false
  customer_managed_key_enforcement_enabled = true
  semantic_search_sku = "standard"
  public_network_access_enabled = true
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
}
*/



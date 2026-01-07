resource "azapi_resource" "aiservices" {
  type      = "Microsoft.CognitiveServices/accounts@2025-09-01"
  name      = "test-cs-account-rai-proj2"
  parent_id = azurerm_resource_group.main.id
  location  = "East US"

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  schema_validation_enabled = false

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    properties = {
      allowProjectManagement = true
      publicNetworkAccess = "Enabled"
      customSubdomainName = "test-cs-account-rai-proj2"
    }
  }
}

resource "azapi_resource" "rai_blocklist" {
  for_each  = { for b in var.rai_blocklists : b.name => b }
  type      = "Microsoft.CognitiveServices/accounts/raiBlocklists@2024-10-01"
  parent_id = azapi_resource.aiservices.id
  name      = each.key
  schema_validation_enabled = false

  body = {
    properties = {
      description = each.value.description
    }
  }
}

// Batch add RAI blocklist items using the addRaiBlocklistItems action.
// Request schema: array of items with name and properties (pattern, isRegex).
// Example:
//   [
//     { "name": "item-0", "properties": { "pattern": "badword1", "isRegex": false } },
//     { "name": "item-1", "properties": { "pattern": "badword2", "isRegex": false } }
//   ]
resource "azapi_resource_action" "rai_blocklist_items_batch" {
  for_each = { for b in var.rai_blocklists : b.name => b if length(coalesce(b.entries, [])) > 0 }

  type        = "Microsoft.CognitiveServices/accounts/raiBlocklists@2024-10-01"
  resource_id = azapi_resource.rai_blocklist[each.key].id
  action      = "addRaiBlocklistItems"
  method      = "POST"

  body = [for idx, e in coalesce(each.value.entries, []) : {
    name       = "item-${idx}"
    properties = {
      pattern = e
      isRegex = false
    }
  }]

  depends_on = [azapi_resource.rai_blocklist]
  response_export_values = ["*"]
}


#--------------------------------------------
# RAI Policies for Cognitive Services Account
#--------------------------------------------
/*
resource "azapi_resource" "raipolicy" {
  type      = "Microsoft.CognitiveServices/accounts/raiPolicies@2024-10-01"
  name      = "custom-rai-policy"
  parent_id = azapi_resource.aiservices.id

  schema_validation_enabled = false

  body = {
    properties = {
      basePolicyName  = "Microsoft.Default"
      mode            = var.rai_policy_mode
      contentFilters  = var.content_filters
      customTopics    = var.custom_topics
      safetyProviders = var.safety_providers
      customBlocklists = [
        for blocklist_name in var.rai_blocklists[*].name : {
          blocklistName = blocklist_name
          blocking      = true
          source        = "Prompt"
        }
      ]
    }
  }

  depends_on = [azapi_resource.rai_blocklist, azapi_resource_action.rai_blocklist_items_batch]
}
*/


resource "azapi_resource" "project" {
  for_each  = var.enable_projects ? { for p in var.projects : p.name => p } : {}
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  parent_id = azapi_resource.aiservices.id
  name      = each.value.name
  location  = azapi_resource.aiservices.location
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  body = {
    properties = {
      displayName = each.value.displayName
      description = each.value.description
    }
  }
  schema_validation_enabled = false
  response_export_values    = ["*"]
  depends_on = [azapi_resource.aiservices]
}
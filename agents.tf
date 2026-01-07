#--------------------------------------------
# AI Agents for Cognitive Services Projects
#
# Note: AI Agents are created through the AI Foundry SDK/Portal.
# This resource demonstrates the structure for agent creation via Terraform.
# 
# Current API Status: The agents endpoint may require additional setup
# or may be available through the Azure SDK rather than ARM templates.
# Consider using Azure CLI or Portal for agent creation and tools management.
#--------------------------------------------

/*
resource "azapi_resource" "agent" {
  for_each  = { for a in var.agents : "${a.project_name}/${a.name}" => a }
  type      = "Microsoft.CognitiveServices/accounts/projects/agents@2025-07-01-preview"
  parent_id = azapi_resource.project[each.value.project_name].id
  name      = each.value.name
  location  = azapi_resource.aiservices.location

  body = {
    properties = {
      displayName  = each.value.displayName
      description  = each.value.description
      instructions = each.value.instructions
      model = {
        name = each.value.model
      }
      parameters = {
        temperature = each.value.temperature
        top_p       = each.value.top_p
        max_tokens  = 4096
      }
    }
  }

  schema_validation_enabled = false
  response_export_values    = ["*"]
  depends_on                = [azapi_resource.project]
  ignore_missing_property   = true
}
*/

#--------------------------------------------
# Agent Configuration Data - Use for SDK/Portal
#--------------------------------------------
output "agent_configurations" {
  description = "Agent configurations for use with Azure SDK or Portal"
  value = [
    for agent in var.agents : {
      project_name    = agent.project_name
      agent_name      = agent.name
      display_name    = agent.displayName
      description     = agent.description
      instructions    = agent.instructions
      model           = agent.model
      temperature     = agent.temperature
      top_p           = agent.top_p
      max_tokens      = 4096
    }
  ]
}

variable "location" {
  default = "Central India"
}

variable "resource_group_name" {
  default = "rg-aml-test-demo2"
}

variable "aml_name" {
  default = "aml-pscde-eus-test"
}

#--------------------------------------------
# Feature Flags
#--------------------------------------------
variable "enable_projects" {
  description = "Enable creation of AI Foundry projects"
  type        = bool
  default     = true
}

variable "enable_agents" {
  description = "Enable creation of AI agents in projects (requires enable_projects = true)"
  type        = bool
  default     = true
}

# variable "application_insights_id" {
#   type = string
# }
variable "rai_blocklists" {
  description = "List of RAI blocklists to create for the Cognitive Services account"
  type = list(object({
    name        = string
    description = string
    entries     = optional(list(string), [])
  }))
  default = [
    {
      name        = "test-cs-account-rai123-crb-1"
      description = "Example blocklist 1"
      entries     = ["offensive", "inappropriate", "profanity"]
    },
    {
      name        = "test-cs-account-rai123-crb-2"
      description = "Example blocklist 2 - regex patterns"
      entries     = ["^spam.*", "bad.*word"]
    }
  ]
}

#--------------------------------------------
# Content Filter Configuration
#--------------------------------------------
variable "content_filters" {
  description = "List of content filters for RAI policy with validation rules"
  type = list(object({
    name              = string
    enabled           = bool
    severityThreshold = string
    blocking          = bool
    source            = string
  }))

  default = [
    {
      name              = "Hate"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Prompt"
    },
    {
      name              = "Hate"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Completion"
    },
    {
      name              = "Sexual"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Prompt"
    },
    {
      name              = "Sexual"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Completion"
    },
    {
      name              = "Violence"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Prompt"
    },
    {
      name              = "Violence"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Completion"
    },
    {
      name              = "SelfHarm"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Prompt"
    },
    {
      name              = "SelfHarm"
      enabled           = true
      severityThreshold = "Medium"
      blocking          = true
      source            = "Completion"
    }
  ]

  validation {
    condition = alltrue([
      for cf in var.content_filters : contains(
        ["Hate", "Sexual", "Violence", "SelfHarm"],
        cf.name
      )
    ])
    error_message = "Content filter 'name' must be one of: Hate, Sexual, Violence, or SelfHarm."
  }

  validation {
    condition = alltrue([
      for cf in var.content_filters : contains(
        ["Low", "Medium", "High"],
        cf.severityThreshold
      )
    ])
    error_message = "Content filter 'severityThreshold' must be one of: Low, Medium, or High."
  }

  validation {
    condition = alltrue([
      for cf in var.content_filters : contains(
        ["Prompt", "Completion", "PreRun", "PostRun", "PreToolCall", "PostToolCall"],
        cf.source
      )
    ])
    error_message = "Content filter 'source' must be one of: Prompt, Completion, PreRun, PostRun, PreToolCall, or PostToolCall."
  }

  validation {
    condition = alltrue([
      for cf in var.content_filters : cf.blocking == true || cf.blocking == false
    ])
    error_message = "Content filter 'blocking' must be a boolean value (true or false)."
  }
}

#--------------------------------------------
# Custom Topics Configuration
#--------------------------------------------
variable "custom_topics" {
  description = "List of custom topics for RAI policy"
  type = list(object({
    topicName = string
    blocking  = bool
    source    = string
  }))
  default = []

  validation {
    condition = alltrue([
      for ct in var.custom_topics : ct.topicName != ""
    ])
    error_message = "Custom topic 'topicName' cannot be empty."
  }

  validation {
    condition = alltrue([
      for ct in var.custom_topics : contains(
        ["Prompt", "Completion", "PreRun", "PostRun", "PreToolCall", "PostToolCall"],
        ct.source
      )
    ])
    error_message = "Custom topic 'source' must be one of: Prompt, Completion, PreRun, PostRun, PreToolCall, or PostToolCall."
  }

  validation {
    condition = alltrue([
      for ct in var.custom_topics : ct.blocking == true || ct.blocking == false
    ])
    error_message = "Custom topic 'blocking' must be a boolean value (true or false)."
  }
}

#--------------------------------------------
# Safety Providers Configuration
#--------------------------------------------
variable "safety_providers" {
  description = "List of safety providers for RAI policy"
  type = list(object({
    safetyProviderName = string
    blocking           = bool
    source             = string
  }))
  default = []

  validation {
    condition = alltrue([
      for sp in var.safety_providers : sp.safetyProviderName != ""
    ])
    error_message = "Safety provider 'safetyProviderName' cannot be empty."
  }

  validation {
    condition = alltrue([
      for sp in var.safety_providers : contains(
        ["Prompt", "Completion", "PreRun", "PostRun", "PreToolCall", "PostToolCall"],
        sp.source
      )
    ])
    error_message = "Safety provider 'source' must be one of: Prompt, Completion, PreRun, PostRun, PreToolCall, or PostToolCall."
  }

  validation {
    condition = alltrue([
      for sp in var.safety_providers : sp.blocking == true || sp.blocking == false
    ])
    error_message = "Safety provider 'blocking' must be a boolean value (true or false)."
  }
}

#--------------------------------------------
# RAI Policy Mode Configuration
#--------------------------------------------
variable "rai_policy_mode" {
  description = "The mode for the RAI policy. Valid values: Default (0), Deferred (1), Blocking (2), Asynchronous_filter (3). Use 'Asynchronous_filter' after 2025-06-01 (replaces 'Deferred')."
  type        = string
  default     = "Default"

  validation {
    condition = contains(
      ["Default", "Deferred", "Blocking", "Asynchronous_filter"],
      var.rai_policy_mode
    )
    error_message = "RAI policy 'mode' must be one of: Default, Deferred, Blocking, or Asynchronous_filter. Use 'Asynchronous_filter' after 2025-06-01 (replaces 'Deferred')."
  }
}

#--------------------------------------------
# Projects Configuration
#--------------------------------------------
variable "projects" {
  description = "List of projects to create under the Cognitive Services account"
  type = list(object({
    name        = string
    displayName = string
    description = optional(string, "")
  }))
  default = [
    {
      name        = "projects-testing-agents"
      displayName = "project-agents-shiva"
      description = "test project"
    },
    {
      name        = "projects-demo-app"
      displayName = "project-demo-app"
      description = "demo application project"
    }
  ]

  validation {
    condition = alltrue([
      for p in var.projects : can(regex("^[a-z0-9-]+$", p.name))
    ])
    error_message = "Project names must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition = alltrue([
      for p in var.projects : length(p.name) > 0 && length(p.displayName) > 0
    ])
    error_message = "Project name and displayName must not be empty."
  }
}

#--------------------------------------------
# AI Agents Configuration
#--------------------------------------------
variable "agents" {
  description = "List of AI agents to create in projects"
  type = list(object({
    project_name    = string
    name            = string
    displayName     = string
    description     = optional(string, "")
    instructions    = optional(string, "")
    model           = optional(string, "gpt-4o")
    temperature     = optional(number, 1)
    top_p           = optional(number, 1)
  }))
  default = [
    {
      project_name = "projects-testing-agents"
      name         = "agent-data-analyst"
      displayName  = "Data Analyst Agent"
      description  = "Agent for data analysis tasks"
      instructions = "You are a helpful data analyst. Analyze provided data and provide insights."
      model        = "gpt-4o"
      temperature  = 0.7
      top_p        = 0.95
    },
    {
      project_name = "projects-testing-agents"
      name         = "agent-code-reviewer"
      displayName  = "Code Reviewer Agent"
      description  = "Agent for code review and suggestions"
      instructions = "You are an expert code reviewer. Review code for quality, security, and best practices."
      model        = "gpt-4o"
      temperature  = 0.5
      top_p        = 0.9
    },
    {
      project_name = "projects-demo-app"
      name         = "agent-content-creator"
      displayName  = "Content Creator Agent"
      description  = "Agent for content creation"
      instructions = "You are a creative content writer. Generate engaging and original content."
      model        = "gpt-4o"
      temperature  = 0.9
      top_p        = 0.95
    }
  ]

  validation {
    condition = alltrue([
      for a in var.agents : contains(["gpt-4o", "gpt-4-turbo", "gpt-35-turbo"], a.model)
    ])
    error_message = "Agent model must be one of: gpt-4o, gpt-4-turbo, gpt-35-turbo"
  }

  validation {
    condition = alltrue([
      for a in var.agents : a.temperature >= 0 && a.temperature <= 2
    ])
    error_message = "Agent temperature must be between 0 and 2"
  }

  validation {
    condition = alltrue([
      for a in var.agents : a.top_p >= 0 && a.top_p <= 1
    ])
    error_message = "Agent top_p must be between 0 and 1"
  }
}


# Content Filter Validation Rules

## Overview
Comprehensive validation rules have been implemented for content filters in the RAI (Responsible AI) policy configuration. These rules ensure that all content filter parameters conform to Azure Cognitive Services API requirements.

## Validation Rules

### 1. Filter Name Validation
**Field:** `name`  
**Valid Values:** `Hate`, `Sexual`, `Violence`, `SelfHarm`  
**Error Message:** "Content filter 'name' must be one of: Hate, Sexual, Violence, or SelfHarm."

```hcl
validation {
  condition = alltrue([
    for cf in var.content_filters : contains(
      ["Hate", "Sexual", "Violence", "SelfHarm"],
      cf.name
    )
  ])
  error_message = "Content filter 'name' must be one of: Hate, Sexual, Violence, or SelfHarm."
}
```

**Example Usage:**
```hcl
content_filters = [
  {
    name = "Hate"  # ✓ Valid
    # ...
  }
]
```

---

### 2. Severity Threshold Validation
**Field:** `severityThreshold`  
**Valid Values:** `Low`, `Medium`, `High`  
**Error Message:** "Content filter 'severityThreshold' must be one of: Low, Medium, or High."

```hcl
validation {
  condition = alltrue([
    for cf in var.content_filters : contains(
      ["Low", "Medium", "High"],
      cf.severityThreshold
    )
  ])
  error_message = "Content filter 'severityThreshold' must be one of: Low, Medium, or High."
}
```

**Example Usage:**
```hcl
content_filters = [
  {
    severityThreshold = "Medium"  # ✓ Valid
    # ...
  }
]
```

---

### 3. Source Validation
**Field:** `source`  
**Valid Values:** `Prompt`, `Completion`  
**Error Message:** "Content filter 'source' must be one of: Prompt or Completion."

```hcl
validation {
  condition = alltrue([
    for cf in var.content_filters : contains(
      ["Prompt", "Completion"],
      cf.source
    )
  ])
  error_message = "Content filter 'source' must be one of: Prompt or Completion."
}
```

**Example Usage:**
```hcl
content_filters = [
  {
    source = "Prompt"  # ✓ Valid
    # ...
  },
  {
    source = "Completion"  # ✓ Valid
    # ...
  }
]
```

---

### 4. Blocking Flag Validation
**Field:** `blocking`  
**Valid Values:** `true`, `false`  
**Error Message:** "Content filter 'blocking' must be a boolean value (true or false)."

```hcl
validation {
  condition = alltrue([
    for cf in var.content_filters : cf.blocking == true || cf.blocking == false
  ])
  error_message = "Content filter 'blocking' must be a boolean value (true or false)."
}
```

**Example Usage:**
```hcl
content_filters = [
  {
    blocking = true   # ✓ Valid
    # ...
  },
  {
    blocking = false  # ✓ Valid
    # ...
  }
]
```

---

## Testing Validation Rules

### Test 1: Invalid Filter Name
```bash
terraform plan -var='content_filters=[{name="InvalidName", enabled=true, severityThreshold="Medium", blocking=true, source="Prompt"}]'
```
**Result:** Error - "Content filter 'name' must be one of: Hate, Sexual, Violence, or SelfHarm."

### Test 2: Invalid Severity Threshold
```bash
terraform plan -var='content_filters=[{name="Hate", enabled=true, severityThreshold="Critical", blocking=true, source="Prompt"}]'
```
**Result:** Error - "Content filter 'severityThreshold' must be one of: Low, Medium, or High."

### Test 3: Invalid Source
```bash
terraform plan -var='content_filters=[{name="Hate", enabled=true, severityThreshold="Medium", blocking=true, source="Invalid"}]'
```
**Result:** Error - "Content filter 'source' must be one of: Prompt or Completion."

---

## Variable Structure

### Complete Variable Definition
```hcl
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
    # ... additional filters
  ]

  # All validation rules applied here
  validation { ... }
  validation { ... }
  validation { ... }
  validation { ... }
}
```

---

## Default Configuration

The default configuration includes 8 content filters covering all combinations of:
- **Names:** Hate, Sexual, Violence, SelfHarm
- **Sources:** Prompt (user input), Completion (model output)

```hcl
[
  { name = "Hate", enabled = true, severityThreshold = "Medium", blocking = true, source = "Prompt" },
  { name = "Hate", enabled = true, severityThreshold = "Medium", blocking = true, source = "Completion" },
  { name = "Sexual", enabled = true, severityThreshold = "Medium", blocking = true, source = "Prompt" },
  { name = "Sexual", enabled = true, severityThreshold = "Medium", blocking = true, source = "Completion" },
  { name = "Violence", enabled = true, severityThreshold = "Medium", blocking = true, source = "Prompt" },
  { name = "Violence", enabled = true, severityThreshold = "Medium", blocking = true, source = "Completion" },
  { name = "SelfHarm", enabled = true, severityThreshold = "Medium", blocking = true, source = "Prompt" },
  { name = "SelfHarm", enabled = true, severityThreshold = "Medium", blocking = true, source = "Completion" }
]
```

---

## Usage Examples

### Override with Custom Configuration
```bash
terraform apply -var='content_filters=[
  {
    name              = "Hate"
    enabled           = true
    severityThreshold = "Low"
    blocking          = false
    source            = "Prompt"
  }
]'
```

### Using terraform.tfvars
Create `terraform.tfvars`:
```hcl
content_filters = [
  {
    name              = "Hate"
    enabled           = true
    severityThreshold = "High"
    blocking          = true
    source            = "Prompt"
  },
  {
    name              = "Sexual"
    enabled           = true
    severityThreshold = "Medium"
    blocking          = false
    source            = "Completion"
  }
]
```

Then apply:
```bash
terraform apply
```

---

## Validation Execution

Validation rules are executed during:
- `terraform validate` - Syntax and rule validation
- `terraform plan` - Before planning changes
- `terraform apply` - Before applying changes

All validation must pass before resources can be created or modified.

---

## Error Handling

When validation fails, Terraform will display:
1. The variable that failed validation
2. The specific validation rule that was violated
3. The error message with guidance on valid values

**Example Error Output:**
```
Error: Invalid value for variable

  on variables.tf line 40:
  40: variable "content_filters" {

Content filter 'name' must be one of: Hate, Sexual, Violence, or SelfHarm.

This was checked by the validation rule at variables.tf:109,3-13.
```

---

## Summary

| Field | Valid Values | Type | Required |
|-------|-------------|------|----------|
| name | Hate, Sexual, Violence, SelfHarm | string | Yes |
| enabled | true, false | bool | Yes |
| severityThreshold | Low, Medium, High | string | Yes |
| blocking | true, false | bool | Yes |
| source | Prompt, Completion | string | Yes |

All validation rules are enforced at Terraform validation time, providing immediate feedback to prevent invalid configurations.

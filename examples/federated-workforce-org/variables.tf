variable "org_id" {
  type        = string
  description = "Existing Atlas org ID connected to the federation in FMC."

  validation {
    condition     = length(var.org_id) > 0
    error_message = "org_id must not be empty."
  }
}

variable "federation_settings_id" {
  type        = string
  description = "Federation settings ID from federation-workforce-idp-okta bootstrap."

  validation {
    condition     = length(var.federation_settings_id) > 0
    error_message = "federation_settings_id must not be empty."
  }
}

variable "workforce_idp_id" {
  type        = string
  description = "24-hex workforce IdP id from bootstrap output workforce_idp_id."

  validation {
    condition     = length(var.workforce_idp_id) > 0
    error_message = "workforce_idp_id must not be empty."
  }
}

variable "post_auth_role_grants" {
  type        = list(string)
  default     = ["ORG_MEMBER"]
  description = "Default organization roles granted to federated users after authentication."
}

variable "role_mappings" {
  description = <<-EOT
    IdP group to Atlas roles. See https://www.mongodb.com/docs/atlas/security/manage-role-mapping/
    org_roles: organization roles on var.org_id.
    project_roles: optional map of existing project_id to project roles.
  EOT
  type = map(object({
    external_group_name = string
    org_roles           = list(string)
    project_roles       = optional(map(list(string)), {})
  }))

  validation {
    condition = alltrue([
      for entry in var.role_mappings :
      length(entry.org_roles) > 0 || length(entry.project_roles) > 0
    ])
    error_message = "Each role_mappings entry must set org_roles and/or project_roles."
  }
}

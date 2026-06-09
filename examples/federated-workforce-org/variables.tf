variable "org_id" {
  type        = string
  description = "Existing Atlas org ID connected to the federation in FMC. Terraform looks up federation_settings_id from this org."

  validation {
    condition     = length(var.org_id) > 0
    error_message = "org_id must not be empty."
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
    IdP group to Atlas roles. One mongodbatlas_federated_settings_org_role_mapping per map entry.
    See https://www.mongodb.com/docs/atlas/security/manage-role-mapping/

    org_roles: Organization roles granted on var.org_id (for example ORG_OWNER, ORG_READ_ONLY).
    project_roles: Optional map of existing Atlas project_id to project roles (for example GROUP_OWNER).
      Use FMC or the Projects API to find project_id; this example does not create projects.

    Example:
    role_mappings = {
      org_owners = {
        external_group_name = "atlas-org-owners"
        org_roles           = ["ORG_OWNER"]
      }
      org_readers = {
        external_group_name = "atlas-org-readers"
        org_roles           = ["ORG_READ_ONLY"]
      }
      dev_project_owners = {
        external_group_name = "atlas-dev-owners"
        org_roles           = ["ORG_MEMBER"]
        project_roles = {
          "YOUR_EXISTING_PROJECT_ID" = ["GROUP_OWNER"]
        }
      }
    }
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

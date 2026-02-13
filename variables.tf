variable "name" {
  description = "Name of the organization. Required when creating a new organization (org_id is not set)."
  type        = string
  default     = null

  validation {
    condition     = var.existing_org_id != null || var.name != null
    error_message = "Variable name is required when creating a new organization (existing_org_id is not set)."
  }
}

variable "existing_org_id" {
  description = "ID of an existing organization to manage. When set, the module skips creation and uses this org instead."
  type        = string
  default     = null

  # Existing org: creation-only attrs and organization_settings must not be set.
  validation {
    condition = var.existing_org_id != null ? alltrue([
      var.org_owner_id == null,
      var.description == null,
      var.role_names == null,
      var.federation_settings_id == null,
      var.organization_settings == null,
    ]) : true
    error_message = "Variables org_owner_id, description, role_names, federation_settings_id, and organization_settings must not be set when using an existing organization (existing_org_id is provided)."
  }

  # New org: required creation attrs must be provided.
  validation {
    condition     = var.existing_org_id != null || var.org_owner_id != null
    error_message = "Variable org_owner_id is required when creating a new organization."
  }

  validation {
    condition     = var.existing_org_id != null || var.description != null
    error_message = "Variable description is required when creating a new organization."
  }

  validation {
    condition     = var.existing_org_id != null || var.role_names != null
    error_message = "Variable role_names is required when creating a new organization."
  }
}

# tflint-ignore: terraform_unused_declarations # TODO: CLOUDP-379748 will wire this to the resource_policy submodule
variable "resource_policies" {
  description = "Resource policy configuration. When set, the resource_policy submodule is enabled. All policies are opt-in: set individual policies to enforce them."
  type = object({
    block_wildcard_ip              = optional(bool, false)
    require_maintenance_window     = optional(bool, false)
    cluster_tier_limits            = optional(object({ min = string, max = string }))
    allowed_cloud_providers        = optional(list(string))
    allowed_regions                = optional(list(string))
    restrict_private_endpoint_mods = optional(bool)
    restrict_vpc_peering_mods      = optional(bool)
    restrict_ip_access_list_mods   = optional(bool)
    tls_ciphers                    = optional(list(string))
  })
  default = null
}

variable "org_owner_id" {
  description = "Atlas user ID to assign as Organization Owner. Required on creation, cannot be updated."
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the initial programmatic API key created with the organization. Required on creation, cannot be updated."
  type        = string
  default     = null
}

variable "role_names" {
  description = "Roles for the initial programmatic API key (e.g. [\"ORG_OWNER\"]). Required on creation, cannot be updated."
  type        = list(string)
  default     = null
}

variable "federation_settings_id" {
  description = "Federation ID to link the new organization to. Cannot be updated after creation."
  type        = string
  default     = null
}

variable "organization_settings" {
  description = "Organization settings to manage. When set, the module configures these on the organization. Must not be set when using existing_org_id (the module does not manage the org resource in that case). Secure-by-default: multi_factor_auth_required and restrict_employee_access default to true."
  type = object({
    api_access_list_required   = optional(bool)
    multi_factor_auth_required = optional(bool, true)
    restrict_employee_access   = optional(bool, true)
    gen_ai_features_enabled    = optional(bool)
    security_contact           = optional(string)
  })
  default = null
}

variable "skip_default_alerts_settings" {
  description = "Skip creation of default alert settings when creating the organization. When null, Atlas applies its own default (false), meaning default org-level alerts are created. See: https://www.mongodb.com/docs/api/doc/atlas-admin-api-v2/operation/operation-createorg"
  type        = bool
  default     = null
}

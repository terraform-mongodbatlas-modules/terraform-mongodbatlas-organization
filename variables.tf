variable "name" {
  description = "Name of the organization. Required when creating a new organization (org_id is not set)."
  type        = string
  default     = null

  validation {
    condition     = var.org_id != null || var.name != null
    error_message = "Variable name is required when creating a new organization (org_id is not set)."
  }
}

variable "org_id" {
  description = "ID of an existing organization to manage. When set, the module skips creation and uses this org instead."
  type        = string
  default     = null

  validation {
    condition = var.org_id != null ? alltrue([
      var.org_owner_id == null,
      var.description == null,
      var.role_names == null,
      var.federation_settings_id == null,
    ]) : true
    error_message = "Variables org_owner_id, description, role_names, and federation_settings_id must not be set when using an existing organization (org_id is provided)."
  }
}

variable "resource_policies" {
  description = "Resource policy configuration. When set, the resource_policy submodule is enabled. Secure-by-default policies (block_wildcard_ip, require_maintenance_window) default to true."
  type = object({
    block_wildcard_ip              = optional(bool, true)
    require_maintenance_window     = optional(bool, true)
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

variable "api_access_list_required" {
  description = "Require API operations to originate from an IP in the organization's API access list."
  type        = bool
  default     = null
}

variable "multi_factor_auth_required" {
  description = "Require users to set up MFA before accessing the organization."
  type        = bool
  default     = null
}

variable "restrict_employee_access" {
  description = "Block MongoDB Support from accessing Atlas infrastructure without explicit permission."
  type        = bool
  default     = null
}

variable "gen_ai_features_enabled" {
  description = "Enable generative AI features for this organization (Atlas Commercial only, defaults to true in Atlas)."
  type        = bool
  default     = null
}

variable "security_contact" {
  description = "Email address to receive security-related notifications for the organization."
  type        = string
  default     = null
}

variable "skip_default_alerts_settings" {
  description = "Skip creation of default alert settings when creating the organization."
  type        = bool
  default     = null
}

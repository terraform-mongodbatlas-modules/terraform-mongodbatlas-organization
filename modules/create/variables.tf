variable "name" {
  description = "Name of the organization."
  type        = string
}

variable "org_owner_id" {
  description = "Atlas user ID to assign as Organization Owner. Required for new organizations, ignored on import."
  type        = string
  default     = null
}

variable "credentials" {
  description = "Credential configuration for the organization. Defaults to Service Account when set. Set type = \"api_key\" for legacy Programmatic API Key. Null for import scenarios where credentials are already configured outside Terraform."
  type = object({
    type                       = optional(string, "service_account")
    name                       = optional(string)
    description                = optional(string)
    roles                      = optional(list(string), ["ORG_OWNER"])
    secret_expires_after_hours = optional(number, 2160)
  })
  default = null

  validation {
    condition     = var.credentials == null ? true : contains(["service_account", "api_key"], var.credentials.type)
    error_message = "credentials.type must be \"service_account\" or \"api_key\"."
  }
}

variable "federation_settings_id" {
  description = "Federation ID to link the new organization to. Cannot be updated after creation."
  type        = string
  default     = null
}

variable "organization_settings" {
  description = "Organization settings to configure on the new organization. Secure-by-default: multi_factor_auth_required and restrict_employee_access default to true."
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

variable "resource_policies" {
  description = "Resource policy configuration. When set, the resource_policy submodule is enabled. All policies are opt-in: set individual policies to enforce them."
  type = object({
    block_wildcard_ip              = optional(bool, false)
    require_maintenance_window     = optional(bool, false)
    cluster_tier_limits            = optional(object({ min = optional(string), max = optional(string) }))
    allowed_cloud_providers        = optional(list(string))
    allowed_regions                = optional(list(string))
    restrict_private_endpoint_mods = optional(bool, false)
    restrict_vpc_peering_mods      = optional(bool, false)
    restrict_ip_access_list_mods   = optional(bool, false)
    tls_ciphers                    = optional(list(string))
  })
  default = null
}

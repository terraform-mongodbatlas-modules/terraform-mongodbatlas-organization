variable "org_id" {
  description = "ID of the existing organization to manage."
  type        = string
}

variable "resource_policies" {
  description = "Resource policy configuration. When set, the resource_policy submodule is enabled. All policies are opt-in: set individual policies to enforce them."
  type = object({
    block_wildcard_ip              = optional(bool, false)
    require_maintenance_window     = optional(bool, false)
    cluster_tier_limits            = optional(object({ min = optional(string), max = optional(string) }))
    allowed_cloud_providers        = optional(list(string))
    allowed_regions                = optional(list(string))
    restrict_private_endpoint_mods = optional(bool)
    restrict_vpc_peering_mods      = optional(bool)
    restrict_ip_access_list_mods   = optional(bool)
    tls_ciphers                    = optional(list(string))
  })
  default = null
}

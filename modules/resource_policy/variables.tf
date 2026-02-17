variable "org_id" {
  description = "The ID of the organization to apply resource policies to."
  type        = string
}

variable "block_wildcard_ip" {
  description = "When true, forbids adding 0.0.0.0/0 to project IP access lists."
  type        = bool
  default     = false
}

variable "require_maintenance_window" {
  description = "When true, forbids cluster modifications in projects that do not have a maintenance window configured."
  type        = bool
  default     = false
}

# TODO: CLOUDP-379749 -- cluster_tier_limits, allowed_cloud_providers, allowed_regions
# TODO: CLOUDP-379750 -- restrict_private_endpoint_mods, restrict_vpc_peering_mods, restrict_ip_access_list_mods, tls_ciphers

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

variable "cluster_tier_limits" {
  description = "When set, restricts cluster tier sizes. Specify min (for example, \"M10\") and/or max (for example, \"M60\") General class instance size bounds."
  type = object({
    min = optional(string)
    max = optional(string)
  })
  default = null

  validation {
    condition     = var.cluster_tier_limits != null ? (var.cluster_tier_limits.min != null || var.cluster_tier_limits.max != null) : true
    error_message = "At least one of min or max must be set when cluster_tier_limits is provided."
  }
}

variable "allowed_cloud_providers" {
  description = "When set, restricts clusters to only the specified cloud providers (for example, [\"aws\", \"azure\"])."
  type        = list(string)
  default     = null
}

variable "allowed_regions" {
  description = "When set, restricts clusters to only the specified regions (for example, [\"aws:us-east-1\", \"azure:westeurope\"])."
  type        = list(string)
  default     = null
}

variable "restrict_private_endpoint_mods" {
  description = "When true, forbids all modifications to private endpoint connections."
  type        = bool
  default     = false
}

variable "restrict_vpc_peering_mods" {
  description = "When true, forbids all modifications to VPC peering connections."
  type        = bool
  default     = false
}

variable "restrict_ip_access_list_mods" {
  description = "When true, forbids all modifications to the project IP access list."
  type        = bool
  default     = false
}

variable "tls_ciphers" {
  description = "When set, restricts clusters to only the specified TLS cipher suites. Requires custom cipher config mode. For the full list of allowed values, see: https://www.mongodb.com/docs/atlas/atlas-resource-policies/#restrict-tls-protocol-and-cipher-suites"
  type        = list(string)
  default     = null
}

output "policy_ids" {
  description = "Map of policy names to their resource IDs. Value is null when the policy is not enabled."
  value = {
    block_wildcard_ip              = var.block_wildcard_ip ? mongodbatlas_resource_policy.block_wildcard_ip[0].id : null
    require_maintenance_window     = var.require_maintenance_window ? mongodbatlas_resource_policy.require_maintenance_window[0].id : null
    cluster_tier_limits            = var.cluster_tier_limits != null ? mongodbatlas_resource_policy.cluster_tier_limits[0].id : null
    allowed_cloud_providers        = var.allowed_cloud_providers != null ? mongodbatlas_resource_policy.allowed_cloud_providers[0].id : null
    allowed_regions                = var.allowed_regions != null ? mongodbatlas_resource_policy.allowed_regions[0].id : null
    restrict_private_endpoint_mods = var.restrict_private_endpoint_mods ? mongodbatlas_resource_policy.restrict_private_endpoint_mods[0].id : null
    restrict_vpc_peering_mods      = var.restrict_vpc_peering_mods ? mongodbatlas_resource_policy.restrict_vpc_peering_mods[0].id : null
    restrict_ip_access_list_mods   = var.restrict_ip_access_list_mods ? mongodbatlas_resource_policy.restrict_ip_access_list_mods[0].id : null
    tls_ciphers                    = var.tls_ciphers != null ? mongodbatlas_resource_policy.tls_ciphers[0].id : null
  }
}

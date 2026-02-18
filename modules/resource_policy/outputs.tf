output "policy_ids" {
  description = "Map of policy names to their resource IDs. Value is null when the policy is not enabled."
  value = {
    block_wildcard_ip          = var.block_wildcard_ip ? mongodbatlas_resource_policy.block_wildcard_ip[0].id : null
    require_maintenance_window = var.require_maintenance_window ? mongodbatlas_resource_policy.require_maintenance_window[0].id : null
    cluster_tier_limits        = var.cluster_tier_limits != null ? mongodbatlas_resource_policy.cluster_tier_limits[0].id : null
    allowed_cloud_providers    = var.allowed_cloud_providers != null ? mongodbatlas_resource_policy.allowed_cloud_providers[0].id : null
    allowed_regions            = var.allowed_regions != null ? mongodbatlas_resource_policy.allowed_regions[0].id : null
  }
}

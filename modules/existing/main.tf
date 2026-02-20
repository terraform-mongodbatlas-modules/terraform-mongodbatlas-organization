module "resource_policy" {
  source = "../resource_policy"
  count  = var.resource_policies != null ? 1 : 0

  org_id                     = var.existing_org_id
  block_wildcard_ip          = var.resource_policies.block_wildcard_ip
  require_maintenance_window = var.resource_policies.require_maintenance_window
  cluster_tier_limits        = var.resource_policies.cluster_tier_limits
  allowed_cloud_providers    = var.resource_policies.allowed_cloud_providers
  allowed_regions            = var.resource_policies.allowed_regions
}

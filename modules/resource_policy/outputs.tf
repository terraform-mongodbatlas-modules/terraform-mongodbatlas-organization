output "policy_ids" {
  description = "Map of policy names to their resource IDs. Value is null when the policy is not enabled."
  value = {
    block_wildcard_ip          = var.block_wildcard_ip ? mongodbatlas_resource_policy.block_wildcard_ip[0].id : null
    require_maintenance_window = var.require_maintenance_window ? mongodbatlas_resource_policy.require_maintenance_window[0].id : null
  }
}

output "org_id" {
  description = "The ID of the managed organization (passthrough)."
  value       = var.org_id
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs. Empty when resource_policies is not set."
  value       = var.resource_policies != null ? module.resource_policy[0].policy_ids : {}
}

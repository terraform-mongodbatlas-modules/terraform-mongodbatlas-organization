output "org_id" {
  description = "The managed organization ID."
  value       = module.atlas_org.org_id
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs."
  value       = module.atlas_org.resource_policy_ids
}

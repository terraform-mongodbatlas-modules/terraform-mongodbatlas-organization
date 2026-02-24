# Note: The create module also outputs public_key and private_key, but these
# are only populated when creating a new organization. When importing, use
# pre-existing credentials to authenticate.

output "org_id" {
  description = "The imported organization ID."
  value       = module.atlas_org.org_id
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs."
  value       = module.atlas_org.resource_policy_ids
}

output "org_id" {
  description = "The created organization ID."
  value       = module.atlas_org.org_id
}

output "client_id" {
  description = "Client ID of the service account created with the organization."
  value       = module.atlas_org.client_id
  sensitive   = true
}

output "client_secret" {
  description = "Client secret of the service account created with the organization."
  value       = module.atlas_org.client_secret
  sensitive   = true
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs."
  value       = module.atlas_org.resource_policy_ids
}

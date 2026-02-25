output "org_id" {
  description = "The created organization ID."
  value       = module.atlas_org.org_id
}

output "public_key" {
  description = "Public key of the PAK created with the organization."
  value       = module.atlas_org.public_key
  sensitive   = true
}

output "private_key" {
  description = "Private key of the PAK created with the organization."
  value       = module.atlas_org.private_key
  sensitive   = true
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs."
  value       = module.atlas_org.resource_policy_ids
}

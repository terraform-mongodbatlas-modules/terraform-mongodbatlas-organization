output "org_id" {
  description = "The ID of the organization (created or existing)."
  value       = local.org_id
}

output "public_key" {
  description = "Public key of the programmatic API key created with the organization. Null when using an existing org."
  value       = local.create_org ? mongodbatlas_organization.this[0].public_key : null
  sensitive   = true
}

output "private_key" {
  description = "Private key of the programmatic API key created with the organization. Null when using an existing org."
  value       = local.create_org ? mongodbatlas_organization.this[0].private_key : null
  sensitive   = true
}

# TODO: CLOUDP-379374 replace null values with actual resource attributes once provider ships SA auto-creation.
output "client_id" {
  description = "Client ID of the service account created with the organization. Null when using an existing org. Requires provider support from CLOUDP-379374."
  value       = null
  sensitive   = true
}

output "client_secret" {
  description = "Client secret of the service account created with the organization. Null when using an existing org. Requires provider support from CLOUDP-379374."
  value       = null
  sensitive   = true
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs. Empty when resource_policies is not set."
  value       = var.resource_policies != null ? module.resource_policy[0].policy_ids : {}
}

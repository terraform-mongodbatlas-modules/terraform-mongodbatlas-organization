output "org_id" {
  description = "The ID of the created organization."
  value       = mongodbatlas_organization.this.org_id
}

output "public_key" {
  description = "Public key of the programmatic API key created with the organization."
  value       = mongodbatlas_organization.this.public_key
  sensitive   = true
}

output "private_key" {
  description = "Private key of the programmatic API key created with the organization."
  value       = mongodbatlas_organization.this.private_key
  sensitive   = true
}

output "client_id" {
  description = "Client ID of the service account created with the organization. Only populated when credentials.type is \"service_account\"."
  value       = try(mongodbatlas_organization.this.service_account[0].client_id, null)
  sensitive   = true
}

output "client_secret" {
  description = "Client secret of the service account created with the organization. Only populated when credentials.type is \"service_account\"."
  value       = try(mongodbatlas_organization.this.service_account[0].secrets[0].secret, null)
  sensitive   = true
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs. Empty when resource_policies is not set."
  value       = var.resource_policies != null ? module.resource_policy[0].policy_ids : {}
}

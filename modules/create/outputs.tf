output "org_id" {
  description = "The ID of the created organization."
  value       = mongodbatlas_organization.this.org_id
}

output "org_managed_credential" {
  description = <<-EOT
    Credentials created with the organization resource (bootstrap only).
    Use these to wire the first provider / CI secret for the new org.
    Do not treat them as the long-lived rotatable credential, use a dedicated
    rotation workflow or external secret store for steady-state.
    Fields follow `credentials.type`: `API_KEY` populates `public_key`/`private_key`,
    `SERVICE_ACCOUNT` populates `client_id`/`client_secret` (other fields are null).
  EOT
  sensitive   = true
  value = {
    public_key    = mongodbatlas_organization.this.public_key
    private_key   = mongodbatlas_organization.this.private_key
    client_id     = try(mongodbatlas_organization.this.service_account[0].client_id, null)
    client_secret = try(mongodbatlas_organization.this.service_account[0].secrets[0].secret, null)
  }
}

output "resource_policy_ids" {
  description = "Map of resource policy names to their IDs. Empty when resource_policies is not set."
  value       = var.resource_policies != null ? module.resource_policy[0].policy_ids : {}
}

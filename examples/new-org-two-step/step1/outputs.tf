output "org_id" {
  description = "The created organization ID. Use in step2."
  value       = module.atlas_org.org_id
}

output "public_key" {
  description = "Public key of the PAK created with the organization. Use in step2 provider config."
  value       = module.atlas_org.public_key
  sensitive   = true
}

output "private_key" {
  description = "Private key of the PAK created with the organization. Use in step2 provider config."
  value       = module.atlas_org.private_key
  sensitive   = true
}

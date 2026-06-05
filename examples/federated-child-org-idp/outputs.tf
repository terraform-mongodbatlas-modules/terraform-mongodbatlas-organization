output "org_id" {
  description = "Child organization ID."
  value       = module.atlas_org.org_id
}

output "public_key" {
  description = "Child organization programmatic API public key."
  value       = module.atlas_org.public_key
  sensitive   = true
}

output "private_key" {
  description = "Child organization programmatic API private key."
  value       = module.atlas_org.private_key
  sensitive   = true
}

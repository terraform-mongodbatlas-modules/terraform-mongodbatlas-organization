output "federation_settings_id" {
  description = "Federation settings ID for this organization."
  value       = local.federation_settings_id
}

output "domain_allow_list" {
  description = "Domains allowed for federated sign-in on this org config (from the workforce IdP associated domains)."
  value       = mongodbatlas_federated_settings_org_config.this.domain_allow_list
}

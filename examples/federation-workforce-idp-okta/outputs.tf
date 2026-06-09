output "federation_settings_id" {
  value = var.federation_settings_id
}

output "workforce_idp_id" {
  description = "24-hex idp_id for federated-workforce-org handoff."
  value       = var.enable_atlas_federation ? mongodbatlas_federated_settings_identity_provider.okta[0].idp_id : null
}

output "okta_idp_certificate" {
  description = "PEM certificate for FMC IdP create (terraform output -raw okta_idp_certificate)."
  value = format(
    "-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----\n",
    replace(okta_app_saml.atlas_lab.certificate, "\n", ""),
  )
  sensitive = true
}

output "okta_idp_issuer" {
  value = okta_app_saml.atlas_lab.entity_url
}

output "okta_idp_sso_url" {
  value = okta_app_saml.atlas_lab.http_post_binding
}

output "saml_phase" {
  description = "1 = Step 1 placeholders; 2 = Step 2 ACS and audience set in tfvars."
  value       = local.saml_phase1 ? 1 : 2
}

output "alice_password" {
  value     = var.create_alice_user ? random_password.alice[0].result : null
  sensitive = true
}

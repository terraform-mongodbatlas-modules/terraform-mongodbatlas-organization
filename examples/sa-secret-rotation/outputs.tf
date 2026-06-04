output "client_id" {
  description = "Service account client ID for provider alias or CI"
  value       = mongodbatlas_service_account.this.client_id
}

output "secret_1_id" {
  description = "Atlas secret ID for secret_1"
  value       = mongodbatlas_service_account_secret.secret_1.secret_id
}

output "secret_2_id" {
  description = "Atlas secret ID for secret_2"
  value       = mongodbatlas_service_account_secret.secret_2.secret_id
}

output "secret_1" {
  description = "Plaintext secret after create or scheduled/manual replace"
  sensitive   = true
  value       = mongodbatlas_service_account_secret.secret_1.secret
}

output "secret_2" {
  description = "Plaintext secret after create or scheduled/manual replace"
  sensitive   = true
  value       = mongodbatlas_service_account_secret.secret_2.secret
}

output "current_credentials" {
  description = "Slot with the latest expires_at (for CI); client_secret null until that slot is replaced"
  sensitive   = true
  value = {
    client_id     = mongodbatlas_service_account.this.client_id
    client_secret = local.active_secret_resource.secret
    secret_id     = local.active_secret_resource.secret_id
    expires_at    = local.active_secret_resource.expires_at
    slot          = local.active_is_secret_1 ? "secret_1" : "secret_2"
  }
}

output "rotation_schedule" {
  description = "Next rotation timestamps from the time provider (apply must run on schedule for rotation to fire)"
  value = {
    phase_a_rotation_rfc3339 = time_rotating.phase_a.rotation_rfc3339
    phase_b_rotation_rfc3339 = time_rotating.phase_b.rotation_rfc3339
  }
}

output "rotation_triggers" {
  description = "Current manual_changes maps; bump a value in tfvars (or -var) and apply to rotate that slot outside the calendar"
  value = {
    secret_1 = var.manual_changes_secret_1
    secret_2 = var.manual_changes_secret_2
  }
}

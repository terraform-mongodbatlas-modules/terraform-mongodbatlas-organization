# mongodbatlas_service_account + two mongodbatlas_service_account_secret resources.
# See README for import, -replace, and time_rotating alternation (rotation.tf).

resource "mongodbatlas_service_account" "this" {
  org_id                     = var.org_id
  name                       = var.service_account_name
  description                = "Scheduled rotation example service account"
  roles                      = var.service_account_roles
  secret_expires_after_hours = var.secret_expires_after_hours
}

# Bootstrap secret from SA create is adopted into Terraform (not created again).
resource "mongodbatlas_service_account_secret" "secret_1" {
  org_id                     = var.org_id
  client_id                  = mongodbatlas_service_account.this.client_id
  secret_expires_after_hours = var.secret_expires_after_hours

  lifecycle {
    ignore_changes       = [secret_expires_after_hours]
    replace_triggered_by = [time_static.phase_a]
  }
}

import {
  to = mongodbatlas_service_account_secret.secret_1
  id = "${var.org_id}/${mongodbatlas_service_account.this.client_id}/${mongodbatlas_service_account.this.secrets[0].secret_id}"
}

# Second secret for overlap during rotation (provider guide pattern).
resource "mongodbatlas_service_account_secret" "secret_2" {
  org_id                     = var.org_id
  client_id                  = mongodbatlas_service_account.this.client_id
  secret_expires_after_hours = var.secret_expires_after_hours

  lifecycle {
    replace_triggered_by = [time_static.phase_b]
  }
}

locals {
  active_is_secret_1 = timecmp(
    mongodbatlas_service_account_secret.secret_1.expires_at,
    mongodbatlas_service_account_secret.secret_2.expires_at,
  ) >= 0

  active_secret_resource = (
    local.active_is_secret_1
    ? mongodbatlas_service_account_secret.secret_1
    : mongodbatlas_service_account_secret.secret_2
  )
}

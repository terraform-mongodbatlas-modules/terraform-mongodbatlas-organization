# Calendar alternation: two independent time_rotating clocks, staggered by half a period.
#
# time_rotating  — schedule (when apply runs past rotation_rfc3339, the clock rolls).
# time_static    — replace_triggered_by target (not time_rotating directly; see provider-time #118).
#
# phase_b uses a one-time half-period offset from first_time_apply when only one bootstrap
# secret exists; after secret_2 exists, phase_b follows rotation_hours only. See README
# section "Rotation clock coupling".

resource "time_rotating" "phase_a" {
  rotation_hours = var.rotation_hours
  triggers       = var.manual_changes_secret_1
}

resource "time_static" "phase_a" {
  rfc3339 = time_rotating.phase_a.rfc3339
}

locals {
  secrets_more_than1 = length(mongodbatlas_service_account.this.secrets) > 1
}

resource "time_static" "first_time_apply" {}

resource "time_rotating" "phase_b" {
  rotation_hours = var.rotation_hours
  rfc3339 = local.secrets_more_than1 ? null : timeadd(
    time_static.first_time_apply.rfc3339,
    "${floor(var.rotation_hours / 2)}h",
  )
  triggers = var.manual_changes_secret_2
}

resource "time_static" "phase_b" {
  rfc3339 = time_rotating.phase_b.rfc3339
}

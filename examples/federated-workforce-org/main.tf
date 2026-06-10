provider "mongodbatlas" {}

data "mongodbatlas_federated_settings" "this" {
  org_id = var.org_id
}

locals {
  federation_settings_id = data.mongodbatlas_federated_settings.this.id
}

data "mongodbatlas_federated_settings_identity_provider" "workforce" {
  federation_settings_id = local.federation_settings_id
  identity_provider_id   = var.workforce_idp_id
}

import {
  id = "${local.federation_settings_id}-${var.org_id}"
  to = mongodbatlas_federated_settings_org_config.this
}

resource "mongodbatlas_federated_settings_org_config" "this" {
  federation_settings_id            = local.federation_settings_id
  org_id                            = var.org_id
  identity_provider_id              = data.mongodbatlas_federated_settings_identity_provider.workforce.okta_idp_id
  data_access_identity_provider_ids = []
  domain_restriction_enabled        = false
  domain_allow_list                 = data.mongodbatlas_federated_settings_identity_provider.workforce.associated_domains
  post_auth_role_grants             = var.post_auth_role_grants
}

resource "mongodbatlas_federated_settings_org_role_mapping" "this" {
  for_each = var.role_mappings

  federation_settings_id = local.federation_settings_id
  org_id                 = var.org_id
  external_group_name    = each.value.external_group_name

  depends_on = [mongodbatlas_federated_settings_org_config.this]

  dynamic "role_assignments" {
    for_each = length(each.value.org_roles) > 0 ? [1] : []
    content {
      org_id = var.org_id
      roles  = each.value.org_roles
    }
  }

  dynamic "role_assignments" {
    for_each = each.value.project_roles
    content {
      group_id = role_assignments.key
      roles    = role_assignments.value
    }
  }
}

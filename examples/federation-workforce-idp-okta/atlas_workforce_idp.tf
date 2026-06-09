provider "mongodbatlas" {}

data "mongodbatlas_federated_settings" "lab" {
  count  = var.enable_atlas_federation ? 1 : 0
  org_id = var.org_id
}

locals {
  okta_issuer_uri        = okta_app_saml.atlas_lab.entity_url
  okta_sso_url           = okta_app_saml.atlas_lab.http_post_binding
  atlas_idp              = var.enable_atlas_federation ? { okta = true } : {}
  federation_settings_id = var.enable_atlas_federation ? data.mongodbatlas_federated_settings.lab[0].id : ""
}

import {
  for_each = local.atlas_idp
  id       = "${local.federation_settings_id}-${var.workforce_idp_id}"
  to       = mongodbatlas_federated_settings_identity_provider.okta[each.key]
}

resource "mongodbatlas_federated_settings_identity_provider" "okta" {
  for_each = local.atlas_idp

  federation_settings_id       = local.federation_settings_id
  idp_type                     = "WORKFORCE"
  name                         = var.atlas_idp_name
  status                       = "ACTIVE"
  associated_domains           = [var.federated_domain]
  issuer_uri                   = local.okta_issuer_uri
  protocol                     = "SAML"
  request_binding              = "HTTP-POST"
  response_signature_algorithm = "SHA-256"
  sso_url                      = local.okta_sso_url
  sso_debug_enabled            = true
}

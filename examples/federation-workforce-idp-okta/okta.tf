provider "okta" {
  org_name  = var.okta_org_name
  base_url  = "okta.com"
  api_token = var.okta_api_token
}

locals {
  saml_phase1 = var.atlas_acs_url == "" || var.atlas_audience == ""
  sso_url     = local.saml_phase1 ? "http://localhost" : var.atlas_acs_url
  audience    = local.saml_phase1 ? "urn:idp:default" : var.atlas_audience
}

resource "okta_app_saml" "atlas_lab" {
  label                    = "MongoDB Atlas Lab"
  status                   = "ACTIVE"
  authentication_policy    = okta_app_signon_policy.atlas_lab.id
  sso_url                  = local.sso_url
  recipient                = local.sso_url
  destination              = local.sso_url
  audience                 = local.audience
  subject_name_id_template = "$${user.email}"
  subject_name_id_format   = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
  user_name_template       = "user.email"
  user_name_template_type  = "CUSTOM"
  response_signed          = true
  assertion_signed         = true
  signature_algorithm      = "RSA_SHA256"
  digest_algorithm         = "SHA256"
  honor_force_authn        = false
  authn_context_class_ref  = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

  dynamic "attribute_statements" {
    for_each = local.saml_phase1 ? [] : [1]
    content {
      type      = "EXPRESSION"
      name      = "firstName"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
      values    = ["user.firstName"]
    }
  }

  dynamic "attribute_statements" {
    for_each = local.saml_phase1 ? [] : [1]
    content {
      type      = "EXPRESSION"
      name      = "lastName"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
      values    = ["user.lastName"]
    }
  }

  dynamic "attribute_statements" {
    for_each = local.saml_phase1 ? [] : [1]
    content {
      type         = "GROUP"
      name         = "memberOf"
      namespace    = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
      filter_type  = "REGEX"
      filter_value = ".*"
    }
  }
}

resource "okta_group" "atlas_org_owners" {
  name        = var.atlas_org_owners_group
  description = "Atlas role mapping via memberOf"
}

resource "random_password" "alice" {
  count = var.create_alice_user ? 1 : 0

  length      = 24
  special     = false
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
}

resource "okta_user" "alice" {
  count = var.create_alice_user ? 1 : 0

  first_name = "Alice"
  last_name  = "Lab"
  login      = coalesce(var.alice_email, "alice@${var.federated_domain}")
  email      = coalesce(var.alice_email, "alice@${var.federated_domain}")
  password   = random_password.alice[0].result
}

resource "okta_group_memberships" "alice_atlas_owners" {
  count = var.create_alice_user ? 1 : 0

  group_id = okta_group.atlas_org_owners.id
  users    = [okta_user.alice[0].id]
}

resource "okta_app_group_assignment" "atlas_lab_owners" {
  app_id   = okta_app_saml.atlas_lab.id
  group_id = okta_group.atlas_org_owners.id
}

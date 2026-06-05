module "atlas_org" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  name                   = var.org_name
  org_owner_id           = var.org_owner_id
  federation_settings_id = var.federation_settings_id
  credentials = {
    type        = "API_KEY"
    description = coalesce(var.org_description, "programmatic API key for ${var.org_name}")
  }
  organization_settings = {
    multi_factor_auth_required = false
    restrict_employee_access   = false
    api_access_list_required   = false
  }
}

resource "mongodbatlas_federated_settings_identity_provider" "idp" {
  federation_settings_id       = var.federation_settings_id
  idp_type                     = var.idp.idp_type
  name                         = var.idp.name
  status                       = var.idp.status
  associated_domains           = var.idp.associated_domains
  issuer_uri                   = var.idp.issuer_uri
  protocol                     = var.idp.protocol
  request_binding              = var.idp.request_binding
  response_signature_algorithm = var.idp.response_signature_algorithm
  sso_debug_enabled            = var.idp.sso_debug_enabled
  sso_url                      = var.idp.sso_url
}

resource "mongodbatlas_federated_settings_org_config" "this" {
  provider                          = mongodbatlas.child_org
  federation_settings_id            = var.federation_settings_id
  org_id                            = module.atlas_org.org_id
  data_access_identity_provider_ids = [var.idp_id]
  domain_restriction_enabled        = false
  domain_allow_list                 = var.idp.associated_domains
  post_auth_role_grants             = var.post_auth_role_grants
  identity_provider_id              = var.okta_idp_id
}

resource "mongodbatlas_federated_settings_org_role_mapping" "org_owner" {
  provider               = mongodbatlas.child_org
  federation_settings_id = var.federation_settings_id
  org_id                 = module.atlas_org.org_id
  external_group_name    = var.external_group_name

  depends_on = [mongodbatlas_federated_settings_org_config.this]

  role_assignments {
    org_id = module.atlas_org.org_id
    roles  = ["ORG_OWNER"]
  }
}

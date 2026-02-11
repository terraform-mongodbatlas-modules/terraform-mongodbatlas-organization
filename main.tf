locals {
  create_org = var.existing_org_id == null
  org_id     = local.create_org ? mongodbatlas_organization.this[0].org_id : var.existing_org_id
}

resource "mongodbatlas_organization" "this" {
  count = local.create_org ? 1 : 0

  name                         = var.name
  org_owner_id                 = var.org_owner_id
  description                  = var.description
  role_names                   = var.role_names
  federation_settings_id       = var.federation_settings_id
  api_access_list_required     = var.organization_settings != null ? var.organization_settings.api_access_list_required : null
  multi_factor_auth_required   = var.organization_settings != null ? var.organization_settings.multi_factor_auth_required : true
  restrict_employee_access     = var.organization_settings != null ? var.organization_settings.restrict_employee_access : true
  gen_ai_features_enabled      = var.organization_settings != null ? var.organization_settings.gen_ai_features_enabled : null
  security_contact             = var.organization_settings != null ? var.organization_settings.security_contact : null
  skip_default_alerts_settings = var.skip_default_alerts_settings
}

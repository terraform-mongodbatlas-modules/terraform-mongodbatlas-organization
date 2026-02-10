locals {
  create_org = var.org_id == null
  org_id     = local.create_org ? mongodbatlas_organization.this[0].org_id : var.org_id
}

resource "mongodbatlas_organization" "this" {
  count = local.create_org ? 1 : 0

  name                         = var.name
  org_owner_id                 = var.org_owner_id
  description                  = var.description
  role_names                   = var.role_names
  federation_settings_id       = var.federation_settings_id
  api_access_list_required     = var.api_access_list_required
  multi_factor_auth_required   = var.multi_factor_auth_required
  restrict_employee_access     = var.restrict_employee_access
  gen_ai_features_enabled      = var.gen_ai_features_enabled
  security_contact             = var.security_contact
  skip_default_alerts_settings = var.skip_default_alerts_settings

  lifecycle {
    precondition {
      condition     = var.org_owner_id != null
      error_message = "Variable org_owner_id is required when creating a new organization."
    }

    precondition {
      condition     = var.description != null
      error_message = "Variable description is required when creating a new organization."
    }

    precondition {
      condition     = var.role_names != null
      error_message = "Variable role_names is required when creating a new organization."
    }
  }
}

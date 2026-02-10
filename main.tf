locals {
  org_id = var.org_id != null ? var.org_id : mongodbatlas_organization.this[0].org_id
}

# Cross-variable input validation. Uses terraform_data (Terraform >= 1.4) because:
# - The org resource has count = 0 when org_id is set, so preconditions inside it are skipped
# - Variable validation blocks cannot cross-reference other variables
# - check blocks produce warnings, not errors
# terraform_data always evaluates (implicit count = 1), has no provider dependency,
# and its lifecycle preconditions produce hard errors at plan time.
resource "terraform_data" "validation" {
  lifecycle {
    precondition {
      condition = var.org_id != null ? alltrue([
        var.org_owner_id == null,
        var.description == null,
        var.role_names == null,
        var.federation_settings_id == null,
      ]) : true
      error_message = "Variables org_owner_id, description, role_names, and federation_settings_id must not be set when using an existing organization (org_id is provided)."
    }

    precondition {
      condition     = var.org_id != null || var.name != null
      error_message = "Variable name is required when creating a new organization (org_id is not set)."
    }
  }
}

resource "mongodbatlas_organization" "this" {
  count = var.org_id == null ? 1 : 0

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

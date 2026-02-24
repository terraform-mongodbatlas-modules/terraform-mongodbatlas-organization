mock_provider "mongodbatlas" {}

variables {
  org_owner_id = "000000000000000000000001"
}

run "create_new_org" {
  command = plan

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name        = "test-org"
    description = "programmatic API key for test-org"
    role_names  = ["ORG_OWNER"]
  }

  assert {
    condition     = mongodbatlas_organization.this.name == "test-org"
    error_message = "Organization name should match."
  }

  assert {
    condition     = mongodbatlas_organization.this.multi_factor_auth_required == true
    error_message = "multi_factor_auth_required should default to true when organization_settings is null."
  }

  assert {
    condition     = mongodbatlas_organization.this.restrict_employee_access == true
    error_message = "restrict_employee_access should default to true when organization_settings is null."
  }

  assert {
    condition     = output.resource_policy_ids == {}
    error_message = "resource_policy_ids should be empty when resource_policies is not set."
  }
}

run "create_org_with_settings" {
  command = plan

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name        = "test-org-full"
    description = "programmatic API key"
    role_names  = ["ORG_OWNER"]
    organization_settings = {
      api_access_list_required   = true
      multi_factor_auth_required = true
      restrict_employee_access   = true
      gen_ai_features_enabled    = false
      security_contact           = "security@example.com"
    }
  }

  assert {
    condition     = mongodbatlas_organization.this.api_access_list_required == true
    error_message = "api_access_list_required should be true."
  }

  assert {
    condition     = mongodbatlas_organization.this.multi_factor_auth_required == true
    error_message = "multi_factor_auth_required should be true."
  }

  assert {
    condition     = mongodbatlas_organization.this.restrict_employee_access == true
    error_message = "restrict_employee_access should be true."
  }

  assert {
    condition     = mongodbatlas_organization.this.security_contact == "security@example.com"
    error_message = "security_contact should be security@example.com."
  }

  assert {
    condition     = output.resource_policy_ids == {}
    error_message = "resource_policy_ids should be empty when resource_policies is not set."
  }
}

run "plan_with_only_name_for_import" {
  command = plan

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    org_owner_id = null
    name         = "imported-org"
  }

  assert {
    condition     = mongodbatlas_organization.this.name == "imported-org"
    error_message = "Organization name should match when only name is provided (import scenario)."
  }

  assert {
    condition     = output.resource_policy_ids == {}
    error_message = "resource_policy_ids should be empty when resource_policies is not set."
  }
}

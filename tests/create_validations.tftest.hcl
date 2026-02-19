mock_provider "mongodbatlas" {}

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
    name         = "test-org"
    org_owner_id = "6578a5f6c776211a7f4e41b2"
    description  = "programmatic API key for test-org"
    role_names   = ["ORG_OWNER"]
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

run "create_org_with_policies" {
  command = plan

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name         = "test-org-policies"
    org_owner_id = "6578a5f6c776211a7f4e41b2"
    description  = "programmatic API key"
    role_names   = ["ORG_OWNER"]
    resource_policies = {
      block_wildcard_ip          = true
      require_maintenance_window = true
    }
  }

  assert {
    condition     = length(module.resource_policy) == 1
    error_message = "resource_policy submodule should be invoked when resource_policies is set."
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "block_wildcard_ip")
    error_message = "resource_policy_ids should contain block_wildcard_ip key."
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "require_maintenance_window")
    error_message = "resource_policy_ids should contain require_maintenance_window key."
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
    name         = "test-org-full"
    org_owner_id = "6578a5f6c776211a7f4e41b2"
    description  = "programmatic API key"
    role_names   = ["ORG_OWNER"]
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

run "create_org_with_all_policies" {
  command = plan

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name         = "test-org-all-policies"
    org_owner_id = "6578a5f6c776211a7f4e41b2"
    description  = "programmatic API key"
    role_names   = ["ORG_OWNER"]
    resource_policies = {
      block_wildcard_ip          = true
      require_maintenance_window = true
      cluster_tier_limits = {
        min = "M10"
        max = "M60"
      }
      allowed_cloud_providers = ["aws"]
      allowed_regions         = ["aws:us-east-1"]
    }
  }

  assert {
    condition     = length(keys(output.resource_policy_ids)) == 5
    error_message = "resource_policy_ids should contain 5 keys when all policies are enabled."
  }
}

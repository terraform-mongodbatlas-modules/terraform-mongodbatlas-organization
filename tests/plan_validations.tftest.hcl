mock_provider "mongodbatlas" {}

run "create_new_org" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = null
    name            = "test-org"
    org_owner_id    = "6578a5f6c776211a7f4e41b2"
    description     = "programmatic API key for test-org"
    role_names      = ["ORG_OWNER"]
  }

  assert {
    condition     = length(mongodbatlas_organization.this) == 1
    error_message = "Expected one organization resource when creating a new org."
  }

  assert {
    condition     = output.resource_policy_ids == {}
    error_message = "resource_policy_ids should be empty when resource_policies is not set."
  }
}

run "use_existing_org" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
  }

  assert {
    condition     = length(mongodbatlas_organization.this) == 0
    error_message = "Expected no organization resource when existing_org_id is provided."
  }

  assert {
    condition     = output.org_id == "6578a5f6c776211a7f4e41b2"
    error_message = "existing_org_id output should match the provided existing_org_id."
  }

  assert {
    condition     = output.public_key == null
    error_message = "public_key should be null when using an existing org."
  }

  assert {
    condition     = output.private_key == null
    error_message = "private_key should be null when using an existing org."
  }

  assert {
    condition     = output.resource_policy_ids == {}
    error_message = "resource_policy_ids should be empty when resource_policies is not set."
  }
}

# Resource policy submodule tests

run "new_org_with_policies_enabled" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = null
    name            = "test-org-policies"
    org_owner_id    = "6578a5f6c776211a7f4e41b2"
    description     = "programmatic API key"
    role_names      = ["ORG_OWNER"]
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

run "existing_org_with_policies" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      block_wildcard_ip = true
    }
  }

  assert {
    condition     = length(mongodbatlas_organization.this) == 0
    error_message = "Expected no organization resource when existing_org_id is provided."
  }

  assert {
    condition     = length(module.resource_policy) == 1
    error_message = "resource_policy submodule should be invoked when resource_policies is set."
  }
}

run "policies_set_but_all_disabled" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      block_wildcard_ip          = false
      require_maintenance_window = false
    }
  }

  assert {
    condition     = length(module.resource_policy) == 1
    error_message = "Submodule should be invoked when resource_policies is set (even if all false)."
  }

  assert {
    condition     = output.resource_policy_ids["block_wildcard_ip"] == null
    error_message = "block_wildcard_ip policy ID should be null when disabled."
  }

  assert {
    condition     = output.resource_policy_ids["require_maintenance_window"] == null
    error_message = "require_maintenance_window policy ID should be null when disabled."
  }

  assert {
    condition     = output.resource_policy_ids["cluster_tier_limits"] == null
    error_message = "cluster_tier_limits policy ID should be null when not set."
  }

  assert {
    condition     = output.resource_policy_ids["allowed_cloud_providers"] == null
    error_message = "allowed_cloud_providers policy ID should be null when not set."
  }

  assert {
    condition     = output.resource_policy_ids["allowed_regions"] == null
    error_message = "allowed_regions policy ID should be null when not set."
  }
}

# Cluster governance policy tests

run "cluster_tier_limits_min_and_max" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      cluster_tier_limits = {
        min = "M10"
        max = "M60"
      }
    }
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "cluster_tier_limits")
    error_message = "resource_policy_ids should contain cluster_tier_limits key."
  }
}

run "cluster_tier_limits_min_only" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      cluster_tier_limits = {
        min = "M10"
      }
    }
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "cluster_tier_limits")
    error_message = "resource_policy_ids should contain cluster_tier_limits key when only min is set."
  }
}

run "cluster_tier_limits_max_only" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      cluster_tier_limits = {
        max = "M60"
      }
    }
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "cluster_tier_limits")
    error_message = "resource_policy_ids should contain cluster_tier_limits key when only max is set."
  }
}

run "allowed_cloud_providers_policy" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      allowed_cloud_providers = ["aws", "gcp"]
    }
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "allowed_cloud_providers")
    error_message = "resource_policy_ids should contain allowed_cloud_providers key."
  }
}

run "allowed_regions_policy" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      allowed_regions = ["aws:us-east-1", "aws:eu-central-1"]
    }
  }

  assert {
    condition     = contains(keys(output.resource_policy_ids), "allowed_regions")
    error_message = "resource_policy_ids should contain allowed_regions key."
  }
}

run "all_cluster_governance_policies" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
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

run "create_org_with_settings" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id            = null
    name                       = "test-org-full"
    org_owner_id               = "6578a5f6c776211a7f4e41b2"
    description                = "programmatic API key"
    role_names                 = ["ORG_OWNER"]
    api_access_list_required   = true
    multi_factor_auth_required = true
    restrict_employee_access   = true
    gen_ai_features_enabled    = false
    security_contact           = "security@example.com"
  }

  assert {
    condition     = length(mongodbatlas_organization.this) == 1
    error_message = "Expected one organization resource."
  }
}

# Validation: creation-only attrs rejected when existing_org_id is set
run "validation_creation_attrs_conflict_with_existing_org_id" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    org_owner_id    = "should-not-be-set"
  }

  expect_failures = [var.existing_org_id]
}

run "validation_description_conflicts_with_existing_org_id" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    description     = "should-not-be-set"
  }

  expect_failures = [var.existing_org_id]
}

run "validation_role_names_conflict_with_existing_org_id" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    role_names      = ["ORG_OWNER"]
  }

  expect_failures = [var.existing_org_id]
}

run "validation_federation_settings_id_conflicts_with_existing_org_id" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id        = "6578a5f6c776211a7f4e41b2"
    federation_settings_id = "should-not-be-set"
  }

  expect_failures = [var.existing_org_id]
}

# Required fields for creation

run "org_owner_id_required" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = null
    name            = "test-org"
    description     = "test key"
    role_names      = ["ORG_OWNER"]
  }

  expect_failures = [var.existing_org_id]
}

run "description_required" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = null
    name            = "test-org"
    org_owner_id    = "6578a5f6c776211a7f4e41b2"
    role_names      = ["ORG_OWNER"]
  }

  expect_failures = [var.existing_org_id]
}

run "role_names_required" {
  command = plan

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    existing_org_id = null
    name            = "test-org"
    org_owner_id    = "6578a5f6c776211a7f4e41b2"
    description     = "test key"
  }

  expect_failures = [var.existing_org_id]
}

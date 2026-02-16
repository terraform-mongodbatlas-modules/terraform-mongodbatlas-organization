mock_provider "mongodbatlas" {}

run "create_new_org" {
  command = plan

  providers = {
    mongodbatlas         = mongodbatlas
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
    error_message = "resource_policy_ids should be empty before submodule wiring."
  }
}

run "use_existing_org" {
  command = plan

  providers = {
    mongodbatlas         = mongodbatlas
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
    error_message = "resource_policy_ids should be empty before submodule wiring."
  }
}

run "create_org_with_settings" {
  command = plan

  providers = {
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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
    mongodbatlas         = mongodbatlas
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

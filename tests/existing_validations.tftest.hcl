mock_provider "mongodbatlas" {}

run "manage_existing_org" {
  command = plan

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
  }

  assert {
    condition     = output.org_id == "6578a5f6c776211a7f4e41b2"
    error_message = "existing_org_id output should match the provided existing_org_id."
  }

  assert {
    condition     = output.resource_policy_ids == {}
    error_message = "resource_policy_ids should be empty when resource_policies is not set."
  }
}

run "manage_org_with_policies" {
  command = plan

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      block_wildcard_ip = true
    }
  }

  assert {
    condition     = length(module.resource_policy) == 1
    error_message = "resource_policy submodule should be invoked when resource_policies is set."
  }
}

run "policies_set_but_all_disabled" {
  command = plan

  module {
    source = "./modules/existing"
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

  module {
    source = "./modules/existing"
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

  module {
    source = "./modules/existing"
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

  module {
    source = "./modules/existing"
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

  module {
    source = "./modules/existing"
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

  module {
    source = "./modules/existing"
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

  module {
    source = "./modules/existing"
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

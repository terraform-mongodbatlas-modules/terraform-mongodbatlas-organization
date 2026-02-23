mock_provider "mongodbatlas" {}

variables {
  existing_org_id = "000000000000000000000001"
}

run "manage_existing_org" {
  command = plan

  module {
    source = "./modules/existing"
  }

  assert {
    condition     = output.org_id == var.existing_org_id
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

  assert {
    condition     = output.resource_policy_ids["restrict_private_endpoint_mods"] == null
    error_message = "restrict_private_endpoint_mods policy ID should be null when not set."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_vpc_peering_mods"] == null
    error_message = "restrict_vpc_peering_mods policy ID should be null when not set."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_ip_access_list_mods"] == null
    error_message = "restrict_ip_access_list_mods policy ID should be null when not set."
  }

  assert {
    condition     = output.resource_policy_ids["tls_ciphers"] == null
    error_message = "tls_ciphers policy ID should be null when not set."
  }
}

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

# Cluster governance policy tests

run "cluster_tier_limits_min_and_max" {
  command = apply

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
    condition     = output.resource_policy_ids["cluster_tier_limits"] != null
    error_message = "cluster_tier_limits policy ID should not be null when enabled."
  }
}

run "cluster_tier_limits_min_only" {
  command = apply

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
    condition     = output.resource_policy_ids["cluster_tier_limits"] != null
    error_message = "cluster_tier_limits policy ID should not be null when only min is set."
  }
}

run "cluster_tier_limits_max_only" {
  command = apply

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
    condition     = output.resource_policy_ids["cluster_tier_limits"] != null
    error_message = "cluster_tier_limits policy ID should not be null when only max is set."
  }
}

run "allowed_cloud_providers_policy" {
  command = apply

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
    condition     = output.resource_policy_ids["allowed_cloud_providers"] != null
    error_message = "allowed_cloud_providers policy ID should not be null when enabled."
  }
}

run "allowed_regions_policy" {
  command = apply

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
    condition     = output.resource_policy_ids["allowed_regions"] != null
    error_message = "allowed_regions policy ID should not be null when enabled."
  }
}

run "all_cluster_governance_policies" {
  command = apply

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
    condition     = output.resource_policy_ids["block_wildcard_ip"] != null
    error_message = "block_wildcard_ip policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["require_maintenance_window"] != null
    error_message = "require_maintenance_window policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["cluster_tier_limits"] != null
    error_message = "cluster_tier_limits policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["allowed_cloud_providers"] != null
    error_message = "allowed_cloud_providers policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["allowed_regions"] != null
    error_message = "allowed_regions policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_private_endpoint_mods"] == null
    error_message = "restrict_private_endpoint_mods should be null when not enabled."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_vpc_peering_mods"] == null
    error_message = "restrict_vpc_peering_mods should be null when not enabled."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_ip_access_list_mods"] == null
    error_message = "restrict_ip_access_list_mods should be null when not enabled."
  }

  assert {
    condition     = output.resource_policy_ids["tls_ciphers"] == null
    error_message = "tls_ciphers should be null when not enabled."
  }
}

# Network and access restriction policy tests

run "restrict_private_endpoint_mods_policy" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      restrict_private_endpoint_mods = true
    }
  }

  assert {
    condition     = output.resource_policy_ids["restrict_private_endpoint_mods"] != null
    error_message = "restrict_private_endpoint_mods policy ID should not be null when enabled."
  }
}

run "restrict_vpc_peering_mods_policy" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      restrict_vpc_peering_mods = true
    }
  }

  assert {
    condition     = output.resource_policy_ids["restrict_vpc_peering_mods"] != null
    error_message = "restrict_vpc_peering_mods policy ID should not be null when enabled."
  }
}

run "restrict_ip_access_list_mods_policy" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      restrict_ip_access_list_mods = true
    }
  }

  assert {
    condition     = output.resource_policy_ids["restrict_ip_access_list_mods"] != null
    error_message = "restrict_ip_access_list_mods policy ID should not be null when enabled."
  }
}

run "tls_ciphers_policy" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      tls_ciphers = ["TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
    }
  }

  assert {
    condition     = output.resource_policy_ids["tls_ciphers"] != null
    error_message = "tls_ciphers policy ID should not be null when enabled."
  }
}

run "tls_ciphers_multiple_suites" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      tls_ciphers = [
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
      ]
    }
  }

  assert {
    condition     = output.resource_policy_ids["tls_ciphers"] != null
    error_message = "tls_ciphers policy ID should not be null when enabled with multiple suites."
  }
}

run "block_wildcard_ip_with_restrict_ip_access_list" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    existing_org_id = "6578a5f6c776211a7f4e41b2"
    resource_policies = {
      block_wildcard_ip            = true
      restrict_ip_access_list_mods = true
    }
  }

  assert {
    condition     = output.resource_policy_ids["block_wildcard_ip"] != null
    error_message = "block_wildcard_ip policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_ip_access_list_mods"] != null
    error_message = "restrict_ip_access_list_mods policy ID should not be null when enabled alongside block_wildcard_ip."
  }
}

run "all_policies" {
  command = apply

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
      allowed_cloud_providers        = ["aws"]
      allowed_regions                = ["aws:us-east-1"]
      restrict_private_endpoint_mods = true
      restrict_vpc_peering_mods      = true
      restrict_ip_access_list_mods   = true
      tls_ciphers                    = ["TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
    }
  }

  assert {
    condition = alltrue([
      for k, v in output.resource_policy_ids : v != null
    ])
    error_message = "All policy IDs should be non-null when every policy is enabled."
  }
}

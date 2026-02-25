mock_provider "mongodbatlas" {}

variables {
  org_owner_id = "000000000000000000000001"
}

run "create_org_sa_outputs" {
  command = apply

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name        = "test-org-sa"
    credentials = { type = "service_account" }
  }

  assert {
    condition     = output.org_id != null
    error_message = "org_id should not be null."
  }

  # client_id is populated by the provider's service_account block.
  # mock_provider returns "" (zero value) which is != null.
  assert {
    condition     = output.client_id != null
    error_message = "client_id should not be null when credentials.type is service_account."
  }
}

run "create_org_with_policies" {
  command = apply

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name        = "test-org-policies"
    credentials = { type = "api_key", description = "org key" }
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
    condition     = output.resource_policy_ids["block_wildcard_ip"] != null
    error_message = "block_wildcard_ip policy ID should not be null when enabled."
  }

  assert {
    condition     = output.resource_policy_ids["require_maintenance_window"] != null
    error_message = "require_maintenance_window policy ID should not be null when enabled."
  }
}

run "create_org_with_all_policies" {
  command = apply

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  variables {
    name        = "test-org-all-policies"
    credentials = { type = "api_key", description = "org key" }
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

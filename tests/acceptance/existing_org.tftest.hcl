# Acceptance tests — applies real resources against an Atlas organization.
# Not auto-discovered by CI; run manually with: just acc-test-org
# Requires MONGODB_ATLAS_CLIENT_ID and MONGODB_ATLAS_CLIENT_SECRET env vars.

variable "org_id" {
  type = string
}

variables {
  existing_org_id = var.org_id
}

run "all_resource_policies" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    resource_policies = {
      block_wildcard_ip              = true
      require_maintenance_window     = true
      cluster_tier_limits            = { min = "M10", max = "M40" }
      allowed_cloud_providers        = ["aws", "gcp"]
      allowed_regions                = ["aws:us-east-1", "aws:eu-central-1"]
      restrict_private_endpoint_mods = true
      restrict_vpc_peering_mods      = true
      restrict_ip_access_list_mods   = true
      tls_ciphers                    = ["TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
    }
  }

  assert {
    condition     = output.org_id == var.org_id
    error_message = "org_id output must match the input org_id."
  }

  assert {
    condition     = output.resource_policy_ids["block_wildcard_ip"] != null
    error_message = "block_wildcard_ip policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["require_maintenance_window"] != null
    error_message = "require_maintenance_window policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["cluster_tier_limits"] != null
    error_message = "cluster_tier_limits policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["allowed_cloud_providers"] != null
    error_message = "allowed_cloud_providers policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["allowed_regions"] != null
    error_message = "allowed_regions policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_private_endpoint_mods"] != null
    error_message = "restrict_private_endpoint_mods policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_vpc_peering_mods"] != null
    error_message = "restrict_vpc_peering_mods policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["restrict_ip_access_list_mods"] != null
    error_message = "restrict_ip_access_list_mods policy ID should not be null."
  }

  assert {
    condition     = output.resource_policy_ids["tls_ciphers"] != null
    error_message = "tls_ciphers policy ID should not be null."
  }
}

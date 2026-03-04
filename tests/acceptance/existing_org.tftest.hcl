# Acceptance tests — applies real resources against an Atlas organization.
# Not auto-discovered by CI; run manually with: just acc-test-org
# Requires MONGODB_ATLAS_CLIENT_ID and MONGODB_ATLAS_CLIENT_SECRET env vars.

variable "org_id" {
  type = string
}

variables {
  existing_org_id = var.org_id
}

run "single_resource_policy" {
  command = apply

  module {
    source = "./modules/existing"
  }

  variables {
    resource_policies = {
      block_wildcard_ip = true
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
}

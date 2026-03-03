# Integration tests — applies real resources against an Atlas organization.
# Requires MONGODB_ATLAS_CLIENT_ID, MONGODB_ATLAS_CLIENT_SECRET env vars
# and org_id passed via: terraform test -var 'org_id=<ATLAS_ORG_ID>'
# Excluded from unit-plan-tests; runs as part of tftest-all (pre-release).

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

# Acceptance tests — creates and destroys a real Atlas organization.
# Not auto-discovered by CI; run manually with: just acc-test-org
# Requires MONGODB_ATLAS_CLIENT_ID, MONGODB_ATLAS_CLIENT_SECRET, and
# MONGODB_ATLAS_ORG_OWNER_ID env vars. The authenticated service account
# must belong to a paying organization.

provider "mongodbatlas" {}

provider "mongodbatlas" {
  alias = "org_creator"
}

# Authenticated with the newly created org's service account.
# Requires base_url when targeting non-production environments (e.g. cloud-dev)
# because explicitly-configured providers don't inherit MONGODB_ATLAS_BASE_URL.
provider "mongodbatlas" {
  alias         = "new_org"
  base_url      = var.base_url
  client_id     = run.create_org_with_sa.client_id
  client_secret = run.create_org_with_sa.client_secret
}

variable "org_id" {
  type = string
}

variable "org_owner_id" {
  type = string
}

variable "base_url" {
  type    = string
  default = null
}

# Covers: new-org-two-step/step1 (create org with SA credentials).
run "create_org_with_sa" {
  command = apply

  module {
    source = "./modules/create"
  }

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.org_creator
  }

  variables {
    name         = "tftest-acceptance"
    org_owner_id = var.org_owner_id
    credentials  = { type = "SERVICE_ACCOUNT" }
  }

  assert {
    condition     = output.org_id != null
    error_message = "org_id should not be null."
  }

  assert {
    condition     = output.client_id != null && length(output.client_id) > 0
    error_message = "client_id should not be null or empty for SERVICE_ACCOUNT credentials."
  }

  assert {
    condition     = output.client_secret != null && length(output.client_secret) > 0
    error_message = "client_secret should not be null or empty for SERVICE_ACCOUNT credentials."
  }
}

# Covers: new-org-two-step/step2 (apply policies on new org using its SA).
# Also the closest approximation of new-org-single-apply, which can't be tested
# in a single run block because terraform test evaluates providers before
# executing the run — unlike terraform apply which resolves them lazily in the
# resource graph.
run "apply_policies_on_new_org" {
  command = apply

  module {
    source = "./modules/existing"
  }

  providers = {
    mongodbatlas = mongodbatlas.new_org
  }

  variables {
    existing_org_id = run.create_org_with_sa.org_id
    resource_policies = {
      block_wildcard_ip = true
    }
  }

  assert {
    condition     = output.resource_policy_ids["block_wildcard_ip"] != null
    error_message = "block_wildcard_ip policy ID should not be null."
  }
}

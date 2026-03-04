# Acceptance tests — creates and destroys a real Atlas organization.
# Not auto-discovered by CI; run manually with: just acc-test-org
# Requires MONGODB_ATLAS_CLIENT_ID, MONGODB_ATLAS_CLIENT_SECRET, and
# MONGODB_ATLAS_ORG_OWNER_ID env vars. The authenticated service account
# must belong to a paying organization.

provider "mongodbatlas" {}

provider "mongodbatlas" {
  alias = "org_creator"
}

variable "org_id" {
  type = string
}

variable "org_owner_id" {
  type = string
}

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
    condition     = output.client_id != null
    error_message = "client_id should not be null for SERVICE_ACCOUNT credentials."
  }
}

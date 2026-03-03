# Integration tests — creates and destroys a real Atlas organization.
# Requires MONGODB_ATLAS_CLIENT_ID, MONGODB_ATLAS_CLIENT_SECRET env vars,
# org_id passed via: terraform test -var 'org_id=<ATLAS_ORG_ID>',
# and TF_VAR_org_owner_id env var set to an Atlas user ID.
# Excluded from unit-plan-tests; runs as part of tftest-all (pre-release).

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
    name         = "tftest-integration"
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

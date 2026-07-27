# Step 1: Create the organization using paying org credentials.
# After apply, use org_managed_credential fields (via step1 public_key/private_key outputs) for step2.

provider "mongodbatlas" {}

module "atlas_org" {
  source = "../../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  name         = var.org_name
  org_owner_id = var.org_owner_id
  credentials  = { type = "API_KEY", description = "programmatic API key for ${var.org_name}" }
}

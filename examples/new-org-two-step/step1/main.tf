# Step 1: Create the organization using paying org credentials.
# After apply, use the public_key and private_key outputs to configure step2.

provider "mongodbatlas" {}

module "atlas_org" {
  source = "../../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  name         = var.org_name
  org_owner_id = var.org_owner_id
  credentials  = { type = "api_key", description = "programmatic API key for ${var.org_name}" }
}

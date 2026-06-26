provider "mongodbatlas" {}

module "atlas_org" {
  source = "../../modules/existing"

  existing_org_id = var.org_id

  maintenance_settings = {
    wave_assignment_mode = "ENV_TAG_MAPPING"
  }
}

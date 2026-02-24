provider "mongodbatlas" {}

module "atlas_org" {
  # When using outside this repo, replace with registry source and version:
  # source  = "terraform-mongodbatlas-modules/organization/mongodbatlas//modules/existing"
  # version = "~> X.Y"
  source = "../../modules/existing"

  existing_org_id = var.org_id

  resource_policies = {
    block_wildcard_ip          = true
    require_maintenance_window = true
    restrict_vpc_peering_mods  = true
    cluster_tier_limits = {
      min = "M10"
      max = "M40"
    }
  }
}

# Single-apply workflow for creating a new organization with resource policies.
#
# The paying org provider (aliased as "paying_org") creates the organization via
# the org_creator configuration. The default provider uses the SA output from
# org creation to manage resource policies in the same apply.

provider "mongodbatlas" {
  # New org credentials -- references module outputs.
  # Terraform resolves these after the organization resource is created.
  client_id     = module.atlas_org.client_id
  client_secret = module.atlas_org.client_secret
}

provider "mongodbatlas" {
  alias = "paying_org"
  # Paying org credentials (via env vars or explicit config).
}

module "atlas_org" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.paying_org
  }

  name         = var.org_name
  org_owner_id = var.org_owner_id
  credentials  = { type = "SERVICE_ACCOUNT" }

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

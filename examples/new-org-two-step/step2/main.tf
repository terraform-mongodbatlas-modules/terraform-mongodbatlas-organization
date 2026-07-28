# Step 2: Apply resource policies using the new org's bootstrap credentials from step1.

provider "mongodbatlas" {
  # Use the org-managed bootstrap credentials from step1:
  #   public_key  = "<public_key from step1>"
  #   private_key = "<private_key from step1>"
  # Or set MONGODB_ATLAS_PUBLIC_KEY / MONGODB_ATLAS_PRIVATE_KEY env vars.
}

module "atlas_org" {
  source = "../../../modules/existing"

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

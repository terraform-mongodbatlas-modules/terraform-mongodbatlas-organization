resource "mongodbatlas_organization" "this" {
  provider = mongodbatlas.org_creator

  name                         = var.name
  org_owner_id                 = var.org_owner_id
  description                  = var.description
  role_names                   = var.role_names
  federation_settings_id       = var.federation_settings_id
  api_access_list_required     = var.organization_settings != null ? var.organization_settings.api_access_list_required : null
  multi_factor_auth_required   = var.organization_settings != null ? var.organization_settings.multi_factor_auth_required : true
  restrict_employee_access     = var.organization_settings != null ? var.organization_settings.restrict_employee_access : true
  gen_ai_features_enabled      = var.organization_settings != null ? var.organization_settings.gen_ai_features_enabled : null
  security_contact             = var.organization_settings != null ? var.organization_settings.security_contact : null
  skip_default_alerts_settings = var.skip_default_alerts_settings
}

module "resource_policy" {
  source = "../resource_policy"
  count  = var.resource_policies != null ? 1 : 0

  org_id                     = mongodbatlas_organization.this.org_id
  block_wildcard_ip          = var.resource_policies.block_wildcard_ip
  require_maintenance_window = var.resource_policies.require_maintenance_window
  cluster_tier_limits        = var.resource_policies.cluster_tier_limits
  allowed_cloud_providers    = var.resource_policies.allowed_cloud_providers
  allowed_regions            = var.resource_policies.allowed_regions
}

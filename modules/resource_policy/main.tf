# Cedar policy syntax reference for Atlas Resource Policies: https://www.mongodb.com/docs/atlas/atlas-resource-policies

locals {
  tier_min_value = try(tonumber(trimprefix(var.cluster_tier_limits.min, "M")), null)
  tier_max_value = try(tonumber(trimprefix(var.cluster_tier_limits.max, "M")), null)

  tier_min_clause = local.tier_min_value != null ? "(context.cluster has minGeneralClassInstanceSizeValue && context.cluster.minGeneralClassInstanceSizeValue < ${local.tier_min_value})" : ""
  tier_max_clause = local.tier_max_value != null ? "(context.cluster has maxGeneralClassInstanceSizeValue && context.cluster.maxGeneralClassInstanceSizeValue > ${local.tier_max_value})" : ""
  tier_when_body  = join(" || ", compact([local.tier_min_clause, local.tier_max_clause]))

  cloud_providers_lower   = var.allowed_cloud_providers != null ? [for p in var.allowed_cloud_providers : lower(p)] : []
  cloud_provider_entities = join(", ", [for p in local.cloud_providers_lower : "ResourcePolicy::CloudProvider::\"${p}\""])

  region_entities = var.allowed_regions != null ? join(", ", [for r in var.allowed_regions : "ResourcePolicy::Region::\"${r}\""]) : ""

  cipher_suite_entities = var.tls_ciphers != null ? join(", ", [for c in var.tls_ciphers : "ResourcePolicy::CipherSuite::\"${c}\""]) : ""
}

resource "mongodbatlas_resource_policy" "block_wildcard_ip" {
  count = var.block_wildcard_ip ? 1 : 0

  org_id = var.org_id
  name   = "block-wildcard-ip"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"project.ipAccessList.modify",
          resource
        )
        when { context.project.ipAccessList.contains(ip("0.0.0.0/0")) };
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "require_maintenance_window" {
  count = var.require_maintenance_window ? 1 : 0

  org_id = var.org_id
  name   = "require-maintenance-window"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"project.maintenanceWindow.modify",
          resource
        )
        when { context.project.hasDefinedMaintenanceWindow == false };
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "cluster_tier_limits" {
  count = var.cluster_tier_limits != null ? 1 : 0

  org_id = var.org_id
  name   = "cluster-tier-limits"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"cluster.modify",
          resource
        )
        when { ${local.tier_when_body} };
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "allowed_cloud_providers" {
  count = var.allowed_cloud_providers != null ? 1 : 0

  org_id = var.org_id
  name   = "allowed-cloud-providers"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"cluster.modify",
          resource
        )
        unless { [${local.cloud_provider_entities}].containsAll(context.cluster.cloudProviders) };
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "allowed_regions" {
  count = var.allowed_regions != null ? 1 : 0

  org_id = var.org_id
  name   = "allowed-regions"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"cluster.modify",
          resource
        )
        unless { [${local.region_entities}].containsAll(context.cluster.regions) };
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "restrict_private_endpoint_mods" {
  count = var.restrict_private_endpoint_mods ? 1 : 0

  org_id = var.org_id
  name   = "restrict-private-endpoint-mods"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"project.privateEndpoint.modify",
          resource
        );
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "restrict_vpc_peering_mods" {
  count = var.restrict_vpc_peering_mods ? 1 : 0

  org_id = var.org_id
  name   = "restrict-vpc-peering-mods"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"project.vpcPeering.modify",
          resource
        );
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "restrict_ip_access_list_mods" {
  count = var.restrict_ip_access_list_mods ? 1 : 0

  org_id = var.org_id
  name   = "restrict-ip-access-list-mods"

  depends_on = [mongodbatlas_resource_policy.block_wildcard_ip]

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"project.ipAccessList.modify",
          resource
        );
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "tls_ciphers" {
  count = var.tls_ciphers != null ? 1 : 0

  org_id = var.org_id
  name   = "tls-ciphers"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"cluster.modify",
          resource
        )
        unless {
          context.cluster.cipherConfigMode == ResourcePolicy::CipherConfigMode::"custom" &&
          [${local.cipher_suite_entities}].containsAll(context.cluster.cipherSuites)
        };
      EOF
    }
  ]
}

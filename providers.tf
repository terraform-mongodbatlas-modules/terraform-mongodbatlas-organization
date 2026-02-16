# This module declares `configuration_aliases = [mongodbatlas.org_creator]` in versions.tf,
# which requires callers to pass the aliased provider via their `providers` block.
#
# However, when running `terraform validate` or `terraform test` directly on this module
# (e.g. in CI), there is no caller -- so Terraform cannot resolve the alias without an
# explicit provider block here. Other Landing Zone modules (project, cluster, CSP) don't
# need this because they use a single default provider with no aliases.
#
# This block carries no configuration and is never used at runtime. Callers always
# override it via `providers = { mongodbatlas.org_creator = ... }`.
provider "mongodbatlas" {
  alias = "org_creator"
}

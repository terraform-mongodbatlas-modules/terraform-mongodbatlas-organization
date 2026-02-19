# Placeholder alias configuration for CI validation and tests.
#
# This module declares `configuration_aliases = [mongodbatlas.org_creator]` in versions.tf,
# which requires callers to pass the aliased provider via their `providers` block.
# When running `terraform validate` or `terraform test` directly on this module (no caller),
# Terraform cannot resolve the alias without an explicit provider block here.
#
# This block is unconfigured (no credentials). Callers must override it via
# `providers = { mongodbatlas.org_creator = ... }` with valid credentials for real runs.
provider "mongodbatlas" {
  alias = "org_creator"
}

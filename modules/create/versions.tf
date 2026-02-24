terraform {
  required_version = ">= 1.9"

  required_providers {
    mongodbatlas = {
      source                = "mongodb/mongodbatlas"
      version               = "~> 2.7"
      configuration_aliases = [mongodbatlas.org_creator]
    }
  }

  # These values are used in the User-Agent Header
  provider_meta "mongodbatlas" {
    module_name    = "organization_create"
    module_version = "local"
  }
}

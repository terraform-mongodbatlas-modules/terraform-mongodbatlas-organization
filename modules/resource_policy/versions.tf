terraform {
  required_version = ">= 1.9"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.7"
    }
  }

  # These values are used in the User-Agent Header
  provider_meta "mongodbatlas" {
    module_name    = "organization_resource_policy"
    module_version = "local"
  }
}

terraform {
  required_version = ">= 1.10"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.15"
    }
  }

  # These values are used in the User-Agent Header
  provider_meta "mongodbatlas" {
    module_name    = "organizationresourcepolicy"
    module_version = "0.2.0"
  }
}

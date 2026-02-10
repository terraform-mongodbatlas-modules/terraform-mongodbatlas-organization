terraform {
  required_version = ">= 1.4"

  required_providers {
    mongodbatlas = {
      source                = "mongodb/mongodbatlas"
      version               = ">= 2.6.0" # TODO: CLOUDP-379763 bump after provider fixes are released
      configuration_aliases = [mongodbatlas.new_org]
    }
  }
}

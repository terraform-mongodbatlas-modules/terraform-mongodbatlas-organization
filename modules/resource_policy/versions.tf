terraform {
  required_version = ">= 1.9"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.6" # TODO: CLOUDP-379763 bump after provider fixes are released
    }
  }
}

terraform {
  required_version = ">= 1.9"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 6.11.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.7"
    }
  }
  required_version = ">= 1.9"
}

provider "mongodbatlas" {}
variable "org_id" {
  type        = string
  description = "Existing organization ID for existing-org and import tests."
}

variable "org_owner_id" {
  type        = string
  description = "Atlas user ID for org creation tests."
  default     = ""
}


locals {
  existing_org_id = var.org_id
}

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

variable "existing_org_id" {
  type        = string
  description = "Existing organization ID for existing-org example."
}

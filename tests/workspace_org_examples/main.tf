terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.15"
    }
  }
  required_version = ">= 1.10"
}

provider "mongodbatlas" {}

# tflint-ignore: terraform_unused_declarations
variable "existing_org_id" {
  type        = string
  description = "Existing organization ID for existing-org example."
}

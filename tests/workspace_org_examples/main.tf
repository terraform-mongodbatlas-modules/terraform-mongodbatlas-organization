terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.9"
}

provider "mongodbatlas" {}

variable "org_owner_id" {
  type        = string
  description = "Atlas user ID for org creation tests."
  default     = ""
}

variable "org_name_prefix" {
  type        = string
  default     = "test-acc-tf-o-"
  description = "org name prefix when auto-generating name."
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "mongodbatlas_organization" "this" {
  name         = "${var.org_name_prefix}${random_string.suffix.id}"
  org_owner_id = var.org_owner_id
  description  = "atlas org used in org module tests"
  role_names   = ["ORG_OWNER"]
}

provider "mongodbatlas" {
  alias       = "existing_org"
  public_key  = mongodbatlas_organization.this.public_key
  private_key = mongodbatlas_organization.this.private_key
}

locals {
  existing_org_id = mongodbatlas_organization.this.org_id
}

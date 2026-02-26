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

provider "mongodbatlas" {
  alias = "org_creator"
}

variable "org_id" {
  type        = string
  description = "Existing organization ID for existing-org and import tests."
  default     = ""
}

variable "org_owner_id" {
  type        = string
  description = "Atlas user ID for org creation tests."
  default     = ""
}

variable "org_name" {
  type        = string
  description = "Name of the existing organization for import tests."
  default     = ""
}

# --- modules/create tests (need dual providers) ---

module "ex_create_with_pak" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.org_creator
  }

  name         = "ws-test-create-pak"
  org_owner_id = var.org_owner_id
  description  = "programmatic API key for ws-test-create-pak"
  role_names   = ["ORG_OWNER"]
}

module "ex_create_with_policies" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.org_creator
  }

  name         = "ws-test-create-policies"
  org_owner_id = var.org_owner_id
  description  = "programmatic API key for ws-test-create-policies"
  role_names   = ["ORG_OWNER"]

  resource_policies = {
    block_wildcard_ip          = true
    require_maintenance_window = true
    restrict_vpc_peering_mods  = true
    cluster_tier_limits = {
      min = "M10"
      max = "M40"
    }
  }
}

module "ex_import" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.org_creator
  }

  name = var.org_name
}

import {
  to = module.ex_import.mongodbatlas_organization.this
  id = var.org_id
}

# --- modules/existing test (single provider) ---

module "ex_existing_org" {
  source = "../../modules/existing"

  existing_org_id = var.org_id

  resource_policies = {
    block_wildcard_ip          = true
    require_maintenance_window = true
    restrict_vpc_peering_mods  = true
    cluster_tier_limits = {
      min = "M10"
      max = "M40"
    }
  }
}

# --- outputs (consumed by ws-output-assertions) ---

output "ex_create_with_pak" {
  value     = module.ex_create_with_pak
  sensitive = true
}

output "ex_create_with_policies" {
  value     = module.ex_create_with_policies
  sensitive = true
}

output "ex_import" {
  value     = module.ex_import
  sensitive = true
}

output "ex_existing_org" {
  value = module.ex_existing_org
}

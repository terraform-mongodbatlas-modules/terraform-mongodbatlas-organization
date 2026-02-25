<!-- @generated
WARNING: This file is auto-generated. Do not edit directly.
Changes will be overwritten when documentation is regenerated.
Run 'just gen-examples' to regenerate.
-->
# Create Organization with Policies (Single Apply)

## Prerequisites

1. Install [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.9).
2. Sign up for a [MongoDB Atlas Account](https://www.mongodb.com/products/integrations/hashicorp-terraform).
3. Configure [authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) via environment variables or provider configuration.

## Commands

```sh
terraform init
# configure your variables in a `terraform.tfvars` file or pass them via -var flags
terraform apply
# cleanup
terraform destroy
```

## Code Snippet

Copy and use this code to get started quickly:

**main.tf**
```hcl
# Single-apply workflow for creating a new organization with resource policies.
#
# The paying org provider (aliased as "paying_org") creates the organization via
# the org_creator configuration. The default provider uses the SA output from
# org creation to manage resource policies in the same apply.

provider "mongodbatlas" {
  # New org credentials -- references module outputs.
  # Terraform resolves these after the organization resource is created.
  client_id     = module.atlas_org.client_id
  client_secret = module.atlas_org.client_secret
}

provider "mongodbatlas" {
  alias = "paying_org"
  # Paying org credentials (via env vars or explicit config).
}

module "atlas_org" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.paying_org
  }

  name         = var.org_name
  org_owner_id = var.org_owner_id
  credentials  = { type = "service_account" }

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
```

**Additional files needed:**
- [outputs.tf](./outputs.tf)
- [variables.tf](./variables.tf)
- [versions.tf](./versions.tf)



## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

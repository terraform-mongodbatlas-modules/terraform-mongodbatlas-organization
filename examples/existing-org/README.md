<!-- @generated
WARNING: This file is auto-generated. Do not edit directly.
Changes will be overwritten when documentation is regenerated.
Run 'just gen-examples' to regenerate.
-->
# Manage Policies on an Existing Organization

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
provider "mongodbatlas" {}

module "atlas_org" {
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
```

**Additional files needed:**
- [outputs.tf](./outputs.tf)
- [variables.tf](./variables.tf)
- [versions.tf](./versions.tf)



## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

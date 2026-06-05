# Create Child Organization and Link IdP

Creates a linked-billing child organization and attaches a pre-existing SAML IdP through federated settings. The child org uses `modules/create`; federation configuration uses provider resources.

`mongodbatlas_federated_settings_org_config` cannot be created. Import the org config shell after the child org exists, then apply to attach the IdP and create role mappings.

## Prerequisites

1. Install [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.9).
2. Sign up for a [MongoDB Atlas Account](https://www.mongodb.com/products/integrations/hashicorp-terraform).
3. Configure [authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) for the paying organization.
4. Complete DNS domain verification and IdP-side SAML configuration before running Terraform.
5. Create the identity provider in federation settings (or follow the [provider federated settings example](https://github.com/mongodb/terraform-provider-mongodbatlas/tree/v2.3.0/examples/mongodbatlas_federated_settings_org_role_mapping) to set one up).
6. Collect `federation_settings_id`, `okta_idp_id`, `idp_id`, `org_owner_id`, and the IdP group for `external_group_name`.

## Commands

```sh
cd examples/federated-child-org-idp
cp terraform.tfvars.example terraform.tfvars
terraform init
```

**Step 1 — Create the child org** (paying org credentials):

```sh
terraform apply -target=module.atlas_org.mongodbatlas_organization.this
```

**Step 2 — Import IdP and org config, configure federation** (child org credentials via `mongodbatlas.child_org` provider):

```sh
terraform apply
```

This apply runs both `import` blocks, updates `mongodbatlas_federated_settings_org_config`, and creates `mongodbatlas_federated_settings_org_role_mapping`.

Confirm a clean plan, then destroy when finished:

```sh
terraform plan
terraform destroy
```

### Import IDs

- **Identity provider**: `{federation_settings_id}-{okta_idp_id}`
- **Org config**: `{federation_settings_id}-{org_id}` (use child org provider)

CLI alternative for the org config import after step 1:

```sh
terraform import \
  -provider=mongodbatlas.child_org \
  'mongodbatlas_federated_settings_org_config.this' \
  "${FEDERATION_SETTINGS_ID}-$(terraform output -raw org_id)"
```

### Common errors

- **`this resource must be imported`**: Run step 1 first, then step 2. `mongodbatlas_federated_settings_org_config` does not support create; import the resource first.
- **Permission errors on org config**: Use the child org PAK on `mongodbatlas.child_org`, not paying org credentials.

## Code Snippet

**main.tf** (excerpt):

```hcl
module "atlas_org" {
  source = "../../modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas
  }

  name                   = var.org_name
  org_owner_id           = var.org_owner_id
  federation_settings_id = var.federation_settings_id
  credentials            = { type = "API_KEY" }
}

import {
  to       = mongodbatlas_federated_settings_org_config.this
  id       = "${var.federation_settings_id}-${module.atlas_org.org_id}"
  provider = mongodbatlas.child_org
}
```

**Additional files needed:**

- [imports.tf](./imports.tf)
- [providers.tf](./providers.tf)
- [variables.tf](./variables.tf)
- [outputs.tf](./outputs.tf)
- [versions.tf](./versions.tf)

## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

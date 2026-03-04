# MongoDB Atlas Organization Terraform Module

## Overview

This Terraform module provides two submodules for managing MongoDB Atlas organizations:

- **[`create`](./modules/create/)**: Provisions a new organization and optionally applies [resource policies](https://www.mongodb.com/docs/atlas/atlas-resource-policies/).
- **[`existing`](./modules/existing/)**: Manages resource policies for an organization that already exists.

Choose the submodule that matches your starting point. For a detailed comparison, see the [modules overview](./modules/README.md).

## Usage

### Create a new organization

```hcl
module "atlas_org" {
  source = "mongodb/organization/mongodbatlas//modules/create"

  providers = {
    mongodbatlas             = mongodbatlas
    mongodbatlas.org_creator = mongodbatlas.paying_org
  }

  name         = "my-new-org"
  org_owner_id = var.user_id
  credentials  = { type = "SERVICE_ACCOUNT" }

  resource_policies = {
    block_wildcard_ip          = true
    require_maintenance_window = true
  }
}
```

### Manage an existing organization

```hcl
module "atlas_org" {
  source = "mongodb/organization/mongodbatlas//modules/existing"

  existing_org_id = var.org_id

  resource_policies = {
    block_wildcard_ip          = true
    require_maintenance_window = true
  }
}
```

For more workflows, see the [examples](./examples/README.md).

## Resources

This module manages the following MongoDB Atlas resources:

- **[Organizations](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/organization)**: Create and configure MongoDB Atlas organizations (via the `create` submodule).
- **[Resource Policies](https://www.mongodb.com/docs/atlas/atlas-resource-policies/)**: Define organization-level controls that constrain how developers create or configure Atlas resources such as clusters, network configurations, and project settings.

## Considerations

### Credential Security
Ensure MongoDB Atlas credentials (API keys, service account secrets) are stored securely using Terraform variables or a secrets management system. Never commit credentials to version control. See the [Atlas authentication guide](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication).

### Permissions
Some operations require Organization Owner privileges. See [MongoDB Atlas organization roles](https://www.mongodb.com/docs/atlas/reference/user-roles/#organization-roles) for details.

### State Management
Store your Terraform state file securely, as it may contain sensitive information about your MongoDB Atlas organization configuration. See [Terraform sensitive data in state](https://developer.hashicorp.com/terraform/language/state/sensitive-data).

### Importing Existing Resources
If importing existing MongoDB Atlas organizations, use the [`import` example](./examples/import/) to bring them into your Terraform state. See [Terraform import](https://developer.hashicorp.com/terraform/cli/import) for general guidance.

## License


<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_INPUTS_RAW -->
<!-- END_TF_INPUTS_RAW -->
<!-- END_TF_DOCS -->

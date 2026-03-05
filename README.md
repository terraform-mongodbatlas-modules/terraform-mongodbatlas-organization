# MongoDB Atlas Organization Terraform Module (Public Preview)

This Terraform module provides two submodules for managing MongoDB Atlas organizations and their [resource policies](https://www.mongodb.com/docs/atlas/atlas-resource-policies/).

- [Public Preview Note](#public-preview-note)
- [Disclaimer](#disclaimer)
- [Overview](#overview)
- [Usage](#usage)
- [Examples](#examples)
- [Resources](#resources)
- [Resource Policies](#resource-policies)
- [Considerations](#considerations)
- [FAQ](#faq)
- [License](#license)

## Public Preview Note

The MongoDB Atlas Organization Module (Public Preview) simplifies organization management and embeds MongoDB's best practices as intelligent defaults. This preview validates that these patterns meet the needs of most workloads without constant maintenance or rework. We welcome your feedback and contributions during this preview phase. MongoDB formally supports this module from its v1 release onwards.

## Disclaimer

One of this project's primary objectives is to provide durable modules that support non-breaking migration and upgrade paths. The v0 release (public preview) of the MongoDB Atlas Organization Module focuses on gathering feedback and refining the design. Upgrades from v0 to v1 may not be seamless.

## Overview

This module can be used in **two different ways**, depending on whether you need to create a new MongoDB Atlas organization or manage one that already exists:

- **[`create`](./modules/create/)**: Provisions a new organization and optionally applies resource policies.
- **[`existing`](./modules/existing/)**: Manages resource policies for an organization that already exists.

### Key Differences

| Aspect | Create | Existing |
|--------|--------|----------|
| **Purpose** | Provisions new organizations | Manages existing organizations |
| **Resource Creation** | Creates organization resources | Does not create organization itself, may create related configuration resources (for example, resource policies) |
| **State Management** | Manages full lifecycle | Manages configuration state of existing organization, not full lifecycle |
| **Use Case** | Greenfield deployments | Brownfield integrations |

### How to Choose

- Choose `create` if your Terraform run is responsible for standing up the organization.
- Choose `existing` if the organization is already present and Terraform should only manage supported add-on configuration.

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

## Examples

| Use Case | Example | Description |
|----------|---------|-------------|
| **Manage resource policies for an already existing organization** | [`existing-org/`](./examples/existing-org/) | Applies resource policies to an organization that already exists in MongoDB Atlas. |
| **Create new organization (single apply)** | [`new-org-single-apply/`](./examples/new-org-single-apply/) | Creates a new organization and apply policies in a single `terraform apply` command. |
| **Create new organization (two-step)** | [`new-org-two-step/`](./examples/new-org-two-step/) | Creates a new organization and apply policies in separate steps. Note: Use this when you cannot use the single-apply workflow. |
| **Import existing organization** | [`import/`](./examples/import/) | Import an already-existing MongoDB Atlas organization into your Terraform state. |

### Prerequisites

All examples require:

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
2. A [MongoDB Atlas Account](https://www.mongodb.com/products/integrations/hashicorp-terraform)
3. Configured [authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) via environment variables or provider configuration

## Resources

This module manages the following MongoDB Atlas resources:

- **[Organizations](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/organization)**: Create and configure MongoDB Atlas organizations (via the `create` submodule).
- **[Resource Policies](https://www.mongodb.com/docs/atlas/atlas-resource-policies/)**: Define organization-level controls that constrain how developers create or configure Atlas resources such as clusters, network configurations, and project settings.

## Resource Policies

[Atlas resource policies](https://www.mongodb.com/docs/atlas/atlas-resource-policies/) enable Organization Owners to constrain the specific configuration options available to developers when they create or configure Atlas resources such as clusters, network configurations, and project settings.

Both submodules provide easy-to-configure resource policies that follow best practices for security, compliance, and operational governance. Policies are opt-in: set individual policies to enforce them.

## Considerations

### Credential Security
Ensure MongoDB Atlas credentials (API keys, service account secrets) are stored securely using Terraform variables or a secrets management system. Never commit credentials to version control. See the [Atlas authentication guide](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication).

### Permissions
Some operations require Organization Owner privileges. See [MongoDB Atlas organization roles](https://www.mongodb.com/docs/atlas/reference/user-roles/#organization-roles) for details.

### State Management
Store your Terraform state file securely, as it may contain sensitive information about your MongoDB Atlas organization configuration. See [Terraform sensitive data in state](https://developer.hashicorp.com/terraform/language/state/sensitive-data).

### Importing Existing Resources
If importing existing MongoDB Atlas organizations, use the [`import` example](./examples/import/) to bring them into your Terraform state. See [Terraform import](https://developer.hashicorp.com/terraform/cli/import) for general guidance.

## FAQ

### Why two submodules instead of a single root module?

The `create` submodule requires two providers: a default provider for the new organization and an aliased `org_creator` provider for the paying organization that creates it. Terraform requires every caller to pass both providers via a `providers` block when a module declares a `configuration_aliases`.

By splitting into two submodules, users managing an existing organization (`existing`) avoid having to define and pass an aliased provider they don't need. This keeps the `existing` workflow simple: one provider, no aliases.

### What is the `provider_meta "mongodbatlas"` doing?

- This block allows us to track the usage of this module by updating the User-Agent of requests to Atlas, for example:
  - `User-Agent: terraform-provider-mongodbatlas/2.1.0 Terraform/1.13.1 module_name/organizationcreate module_version/0.1.0`
- Note: We **do not** send any configuration-specific values, only these values to help us track feature adoption.
- You can use `export TF_LOG=debug` to see the API requests with headers and their responses.

## License

See [LICENSE](./LICENSE) for full details.

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_INPUTS_RAW -->
<!-- END_TF_INPUTS_RAW -->
<!-- END_TF_DOCS -->

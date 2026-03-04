# Organization Module

This module can be used in **two different ways**, depending on whether you need to create a new MongoDB Atlas organization or manage one that already exists.

## Two Ways to Use This Module

1. Use the `create` submodule to create a new organization and manage it.
2. Use the `existing` submodule to connect to an existing organization and manage supported configuration on top of it.

Choose the submodule that matches your lifecycle starting point.

## Submodules

### `create` Submodule
Use this submodule when you need to create a new MongoDB Atlas organization from scratch.

**When to use:**
- Provisioning organizations for new projects or teams
- Setting up multi-tenant environments
- Creating isolated organizational structures

**Quick start:**
```hcl
module "atlas_org" {
	source = "./modules/create"

	# required inputs...
}
```

### `existing` Submodule
Use this submodule when working with pre-existing MongoDB Atlas organizations.

**When to use:**
- Managing configuration of already-created organizations
- Integrating with existing infrastructure
- Avoiding duplicate organization creation

**Quick start:**
```hcl
module "atlas_org" {
	source = "./modules/existing"

	# required inputs...
}
```

## Key Differences

| Aspect | Create | Existing |
|--------|--------|----------|
| **Purpose** | Provisions new organizations | Manages existing organizations |
| **Resource Creation** | Creates organization resources | Does not create organization itself, may create related configuration resources (for example, resource policies) |
| **State Management** | Manages full lifecycle | Manages configuration state of existing organization, not full lifecycle |
| **Use Case** | Greenfield deployments | Brownfield integrations |

## How to Choose

- Choose `create` if your Terraform run is responsible for standing up the organization.
- Choose `existing` if the organization is already present and Terraform should only manage supported add-on configuration.

## Resource Policies

[Atlas resource policies](https://www.mongodb.com/docs/atlas/atlas-resource-policies/) enable Organization Owners to constrain the specific configuration options available to developers when they create or configure Atlas resources such as clusters, network configurations, and project settings.

Both submodules provide easy-to-configure resource policies that follow best practices for security, compliance, and operational governance. Policies are opt-in: set individual policies to enforce them.

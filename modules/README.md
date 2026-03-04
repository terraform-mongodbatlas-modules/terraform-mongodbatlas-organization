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

Resource policies control access and permissions within organizations:

- **Org Owner**: Full administrative access
- **Org Member**: Limited organizational access
- **Custom Roles**: Granularly defined permissions

Policies are applied consistently across both `create` and `existing` submodules to enforce security boundaries and role-based access control.

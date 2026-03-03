# Organization Module

This module provides resources for managing MongoDB Atlas organizations.

## Submodules

### `create` Submodule
Use this submodule when you need to create a new MongoDB Atlas organization from scratch.

**When to use:**
- Provisioning organizations for new projects or teams
- Setting up multi-tenant environments
- Creating isolated organizational structures

### `existing` Submodule
Use this submodule when working with pre-existing MongoDB Atlas organizations.

**When to use:**
- Managing configuration of already-created organizations
- Integrating with existing infrastructure
- Avoiding duplicate organization creation

## Key Differences

| Aspect | Create | Existing |
|--------|--------|----------|
| **Purpose** | Provisions new organizations | Manages existing organizations |
| **Resource Creation** | Creates organization resources | References existing resources |
| **State Management** | Manages full lifecycle | Read-only or limited modifications |
| **Use Case** | Greenfield deployments | Brownfield integrations |

## Resource Policies

Resource policies control access and permissions within organizations:

- **Org Owner**: Full administrative access
- **Org Member**: Limited organizational access
- **Custom Roles**: Granularly defined permissions

Policies are applied consistently across both `create` and `existing` submodules to enforce security boundaries and role-based access control.

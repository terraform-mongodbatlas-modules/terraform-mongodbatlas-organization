# Federated Workforce Org

Configures workforce federation on an **existing** organization: `org_config` import and IdP group role mappings after the org is linked to a federation in the Federation Management Console (FMC).

Multiple Atlas organizations can share one federation. Run the federation-level IdP bootstrap once per federation ([`federation-workforce-idp-okta`](../federation-workforce-idp-okta/) or an Atlas IdP tutorial below). Every organization that joins that federation can run this example with its own `org_id` and Org Owner credentials; it does not have to be the organization that performed the bootstrap.

Complete federation-level IdP bootstrap first (once per federation):
- **Okta lab example**: [`federation-workforce-idp-okta`](../federation-workforce-idp-okta/)
- **Atlas IdP tutorials**: [Microsoft Entra ID](https://www.mongodb.com/docs/atlas/security/federated-auth-azure-ad/), [Google Workspace](https://www.mongodb.com/docs/atlas/security/federated-auth-google-ws/), [Okta](https://www.mongodb.com/docs/atlas/security/federated-auth-okta/), [PingOne](https://www.mongodb.com/docs/atlas/security/federated-auth-ping-one/)

Programmatic child-org creation is a separate workflow not covered by this example.

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
2. Federation bootstrap complete; copy `workforce_idp_id` (24-hex IdP ID from FMC **Identity Providers**) from [`federation-workforce-idp-okta`](../federation-workforce-idp-okta/) outputs or from the Atlas IdP tutorial you used (shared by all orgs in the federation)
3. Access to the [Federation Management Console (FMC)](https://www.mongodb.com/docs/atlas/security/manage-federated-auth/):
   - Sign in to [Atlas](https://cloud.mongodb.com/) and select an organization that can open the federation (for example one already linked to it)
   - In the left sidebar, open **Identity & Access** → **Federation**
   - Under **Federated Authentication Settings**, click **Open Federation Management App** (FMC opens in a new browser tab)
4. **Target organization** linked to the federation and connected to the workforce IdP:
   - Link the organization to the federation using one of the following:
     - **Terraform**: Create the organization with `federation_settings_id` set (for example [`modules/create`](../../modules/create/) or `mongodbatlas_organization.federation_settings_id`). Use the resulting `org_id`.
     - **FMC**: **Organizations** → **Link existing organization** → select the target organization → **Link**
   - Connect the workforce IdP to the organization (required whether you linked via Terraform or FMC): FMC **Organizations** → click the linked row → **Connect Identity Provider**
5. Org Owner API key for the target org (default `mongodbatlas` provider)

## Commands

```sh
cd examples/federated-workforce-org
cp terraform.tfvars.example terraform.tfvars
# Set the 24-hex `org_id` and `workforce_idp_id` in terraform.tfvars. Configure your `role_mappings`, align the `external_group_name` with your IdP groups
terraform init
terraform apply
```

`mongodbatlas_federated_settings_org_config` has no create API; the inline `import` block is required.

Import ID: `{federation_settings_id}-{org_id}` (Terraform resolves `federation_settings_id` from `org_id`).

Expected plan summary (default tfvars with one `role_mappings` entry shown; values will differ):

- **Import**: `mongodbatlas_federated_settings_org_config.this` from `{federation_settings_id}-{org_id}`
- **Update in-place**: Terraform sets `post_auth_role_grants` (default `["ORG_MEMBER"]`) on the imported org config
- **Create**: One `mongodbatlas_federated_settings_org_role_mapping` per `role_mappings` entry
- **Plan**: `1 to import, N to add, 1 to change, 0 to destroy` where `N` is the number of `role_mappings` keys
- **Outputs**: `federation_settings_id` and `domain_allow_list` populate after apply

Example (single `org_owners` mapping; default tfvars after [`federation-workforce-idp-okta`](../federation-workforce-idp-okta/) handoff):

```text
# mongodbatlas_federated_settings_org_config.this will be updated in-place
# (imported from "6a26cec072c5699a2a7594ac-6a26ceb06b8cabb69d79a50d")
~ resource "mongodbatlas_federated_settings_org_config" "this" {
    ~ post_auth_role_grants = [
        + "ORG_MEMBER",
      ]
  }

# mongodbatlas_federated_settings_org_role_mapping.this["org_owners"] will be created
+ resource "mongodbatlas_federated_settings_org_role_mapping" "this" {
    + external_group_name = "atlas-org-owners"
    + role_assignments {
        + roles = ["ORG_OWNER"]
      }
  }

Plan: 1 to import, 1 to add, 1 to change, 0 to destroy.
```

Default tfvars apply org-level mappings only. Uncomment `project_roles` to map an existing `project_id`; this example does not create projects.

## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

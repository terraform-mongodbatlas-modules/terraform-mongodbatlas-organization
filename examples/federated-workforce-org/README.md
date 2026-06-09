# Federated Workforce Org

Configures workforce federation on an **existing** org already connected to the federation in the Federation Management Console (FMC): `org_config` import and IdP group role mappings.

Complete federation-level IdP bootstrap first:
- **Okta lab example**: [`federation-workforce-idp-okta`](../federation-workforce-idp-okta/)
- **Atlas IdP tutorials**: [Microsoft Entra ID](https://www.mongodb.com/docs/atlas/security/federated-auth-azure-ad/), [Google Workspace](https://www.mongodb.com/docs/atlas/security/federated-auth-google-ws/), [Okta](https://www.mongodb.com/docs/atlas/security/federated-auth-okta/), [PingOne](https://www.mongodb.com/docs/atlas/security/federated-auth-ping-one/)

Programmatic child-org creation is a separate workflow not covered by this example.

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
2. Bootstrap complete; copy `workforce_idp_id` from [`federation-workforce-idp-okta`](../federation-workforce-idp-okta/) outputs
3. Target `org_id` (same lab Atlas org) exists and is connected to the federation in FMC. Terraform reads `federation_settings_id` from [`mongodbatlas_federated_settings`](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/federated_settings) using `org_id`.
4. Org Owner API key for the target org (default `mongodbatlas` provider)

## Commands

```sh
cd examples/federated-workforce-org
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Plan fails at the `linked` data source if `org_id` is not in the federation.

`mongodbatlas_federated_settings_org_config` has no create API; the inline `import` block is required.

Import ID: `{federation_settings_id}-{org_id}` (Terraform resolves `federation_settings_id` from `org_id`).

## Role mappings

Default tfvars apply org-level mappings only. Uncomment `project_roles` to map an existing `project_id`; this example does not create projects.

## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

# Federated Workforce Org

Configures workforce federation on an **existing** org already connected to the federation in FMC: `org_config` import and IdP group role mappings. Complete [`federation-workforce-idp-okta`](../federation-workforce-idp-okta/) first.

Programmatic child-org creation is a separate workflow ([HELP-86136](https://jira.mongodb.org/browse/HELP-86136)).

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
2. Bootstrap complete; copy `federation_settings_id` and `workforce_idp_id` from bootstrap outputs
3. Target `org_id` exists and is connected to the federation in FMC
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

Import ID: `{federation_settings_id}-{org_id}`.

## Role mappings

Default tfvars apply org-level mappings only. Uncomment `project_roles` to map an existing `project_id`; this example does not create projects.

## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

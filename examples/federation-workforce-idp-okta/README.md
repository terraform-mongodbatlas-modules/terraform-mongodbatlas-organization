# Federation Workforce IdP (Okta)

Bootstraps a federation-level Okta SAML workforce IdP: Okta app, users, groups, and Atlas workforce IdP import. Run once per federation. Hand off `workforce_idp_id` to [`federated-workforce-org`](../federated-workforce-org/) for each organization that joins the federation.

Together with the org example, this end state lets workforce users sign in to Atlas through SAML single sign-on (SSO). Okta manages users and groups, and Atlas maps IdP groups to organization roles.

This is a **lab example**. Several steps relax security controls so you can complete SAML federation quickly in a throwaway Okta Integrator org and a dedicated **lab Atlas org**. Do not copy these patterns into production without hardening.

## Lab shortcuts (not for production)

- **Password-only sign-in (MFA skipped)**: `okta_mfa.tf` scopes password-only MFA enrollment, global session (`mfa_required = false`), and 1FA app sign-on to `atlas_org_owners_group` only. Other Okta users keep your org defaults.
- **Synthetic test user**: Optional `create_alice_user` provisions a lab user with a `random` provider password. Retrieve `alice_email` and `alice_password` with `terraform output`. Federated Atlas login works only after [`federated-workforce-org`](../federated-workforce-org/) role mappings are applied.
- **SAML placeholders**: Step 1 applies `okta_app_saml` with `http://localhost` and `urn:idp:default` until FMC returns real ACS and audience values in Step 2.
- **Atlas SSO debug**: `sso_debug_enabled = true` on the imported workforce IdP aids FMC troubleshooting; disable in production.
- **ForceAuthn disabled**: `honor_force_authn = false` on the Okta SAML app reduces friction during login tests.
- **DNS outside this example**: Domain TXT verification is not in this example root module. Step 4 shows an inline [Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) Terraform snippet you can add in a separate stack or one-off apply.
- **Okta Integrator limits**: Free-plan orgs cap active users and deactivate after 180 days without login.

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.10
2. [Okta Integrator](https://developer.okta.com/docs/reference/org-defaults/) org and API token:
   - **Sign up**: [Okta developer signup](https://developer.okta.com/signup/) → **Workforce Identity** → **Integrator Free Plan**.
   - **Activate**: Open the verification email and complete org activation. Note your org URL (for example `integrator-7930367.okta.com`) and set `okta_org_name` in [`terraform.tfvars.example`](./terraform.tfvars.example) to the subdomain (`integrator-7930367`).
   - **API token**: Okta admin console → **Security** → **API** → **Tokens** → **Create token**. Store as `OKTA_API_TOKEN`, `TF_VAR_okta_api_token`, or in gitignored `terraform.tfvars` (`okta_api_token`). You can't create API tokens via Terraform.
3. **Lab Atlas org** with **Organization Owner** credentials (create a dedicated org for federation testing. Do not use production). Note the 24-hex `org_id` from Atlas **Organization Settings** for Step 6.
4. Access to the [Federation Management Console (FMC)](https://www.mongodb.com/docs/atlas/security/manage-federated-auth/) for the lab Atlas org:
   - Sign in to [Atlas](https://cloud.mongodb.com/) and select the lab Atlas org from the **Organizations** menu in the top navigation bar
   - In the left sidebar, open **Identity & Access** → **Federation**
   - Under **Federated Authentication Settings**, click **Open Federation Management App** (FMC opens in a new browser tab)
   - In FMC, use the left navigation: **Identity Providers** (create IdP, associate domains), **Domains** (TXT verification), **Organizations** (connect lab Atlas org to IdP)
5. DNS control for `federated_domain`

## Apply order

### Step 1 — Create Okta app and register certificate in FMC

Initialize the module and create the Okta SAML app with placeholder ACS and audience values, then export the IdP certificate for FMC:

```sh
cd examples/federation-workforce-idp-okta
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply   # Okta SAML app with placeholder ACS/audience
terraform output -raw okta_idp_certificate > okta.pem
```

Leave `atlas_acs_url` and `atlas_audience` at their defaults for this step (the commented placeholders in `terraform.tfvars`).

In FMC (see [Prerequisites](#prerequisites)), open **Identity Providers** → **Setup Identity Provider** (or **Add Identity Provider** if one already exists). Select **Workforce Identity Federation**, then **SAML** for Atlas UI access, then:

| FMC field | Value |
| --- | --- |
| Issuer URI / SSO URL | Placeholder values (per [Atlas Okta guide](https://www.mongodb.com/docs/atlas/security/federated-auth-okta/)) |
| Certificate | Paste `okta.pem` |
| Request binding | HTTP POST |
| Response signature algorithm | SHA-256 |

Click **Next**, copy **Assertion Consumer Service URL** and **Audience URI**, then **Finish**.

### Step 2 — Wire Okta SAML to Atlas metadata

Uncomment and set `atlas_acs_url` and `atlas_audience` in `terraform.tfvars` from the FMC metadata, then `terraform apply`.

### Step 3 — Users (optional)

```sh
export TF_VAR_create_alice_user=true
terraform apply
terraform output -raw alice_email
terraform output -raw alice_password
```

Creates the lab user and its `atlas_org_owners_group` membership. `atlas_org_owners_group`, app assignment, and the password-only policies in `okta_mfa.tf` are created regardless of `create_alice_user`.

- **`alice_email`**: Federated login username at Atlas (default `alice@${federated_domain}`; must match the verified domain from Step 4).
- **`alice_password`**: Okta password for the lab user (Okta sign-in only; not an Atlas local password).

Save both outputs for the login test after [`federated-workforce-org`](../federated-workforce-org/) is complete (see **Test federated login** below).

### Step 4 — Add domain, DNS TXT, verify, associate with IdP, and activate (manual)

FMC → Domains → Add Domain → `federated_domain` → DNS Record. Copy the 32-character token (without the `mongodb-site-verification=` prefix).

**Route 53 (Terraform)** when the domain is in a hosted zone. Add to a separate file or stack (not included in this example):

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_route53_record" "atlas_domain_verify" {
  zone_id = "Z0123456789ABCDEFGHIJ" # Route 53 hosted zone ID
  name    = "test-federated.example.com"
  type    = "TXT"
  ttl     = 300
  records = ["mongodb-site-verification=YOUR_32_CHAR_TOKEN"]
}
```

Apply the stack to create the DNS TXT record:

```sh
terraform apply
```

Confirm propagation, then click **verify** in FMC:

```sh
dig TXT +short "your-federated-domain.example.com"  # replace with your federated_domain value
```

FMC → **Identity Providers** → select the **Workforce Identity Federation** SAML IdP from Step 1 → **Associate Domains** → select the verified `federated_domain` → **Confirm**.

On the same IdP row, open **Manage** → **Activate Identity Provider**. Copy the **IdP ID** by clicking the symbol.

Use your registrar or another DNS stack if you are not on Route 53; the TXT value format is the same.

### Step 5 — Connect lab Atlas org in FMC

In FMC, open **Organizations** → select the lab Atlas org → **Connect Identity Provider**.

### Step 6 — Import Atlas IdP

Set the following values in `terraform.tfvars` using the `org_id` from [Prerequisites](#prerequisites) and the IdP ID from Step 4:

```hcl
enable_atlas_federation = true
org_id                  = "..." # lab Atlas org from Prerequisites
workforce_idp_id        = "..." # 24-hex IdP ID from Step 4
```

Terraform reads `federation_settings_id` from [`mongodbatlas_federated_settings`](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/federated_settings) using `org_id`.

Apply to import the Atlas workforce IdP:

```sh
terraform apply
```

Import ID: `{federation_settings_id}-{workforce_idp_id}`.

Expected plan summary:

- **Import**: `mongodbatlas_federated_settings_identity_provider.okta["okta"]` from `{federation_settings_id}-{workforce_idp_id}`
- **Update in-place**: Terraform replaces FMC placeholder SAML values and the FMC configuration name with values from this module:
  - `issuer_uri`: `urn:idp:default` → Okta entity URL
  - `sso_url`: `http://localhost` → Okta SSO URL
  - `name`: FMC label (for example `okta`) → `atlas_idp_name` (default `Okta Lab`)
- **Plan**: `1 to import, 0 to add, 1 to change, 0 to destroy`
- **Outputs**: `federation_settings_id` and `workforce_idp_id` populate after apply

Example (values will differ):

```text
# mongodbatlas_federated_settings_identity_provider.okta["okta"] will be updated in-place
# (imported from "6a26cec072c5699a2a7594ac-6a27b2b4634efca55f876735")
~ resource "mongodbatlas_federated_settings_identity_provider" "okta" {
    ~ issuer_uri = "urn:idp:default" -> "http://www.okta.com/exk..."
    ~ name       = "okta" -> "Okta Lab"
    ~ sso_url    = "http://localhost" -> "https://integrator-7930367.okta.com/app/.../sso/saml"
      status     = "ACTIVE"
  }

Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.
```

## Handoff

Copy `workforce_idp_id` into [`federated-workforce-org/terraform.tfvars.example`](../federated-workforce-org/terraform.tfvars.example) for each organization that joins the federation (`terraform output -raw workforce_idp_id`). Set `org_id` to the organization you are configuring in that example; it does not have to be the organization used during bootstrap.

## Test federated login

Run this test only after going through the steps 1–6 detailed in the [Apply order](#apply-order) section **and** a successful `terraform apply` in [`federated-workforce-org`](../federated-workforce-org/).

1. In `federated-workforce-org/terraform.tfvars`, map the lab user's Okta group (`atlas_org_owners_group`, default `atlas-org-owners`) to Atlas org roles. Example:

```hcl
role_mappings = {
  org_owners = {
    external_group_name = "atlas-org-owners"
    org_roles           = ["ORG_OWNER"]
  }
}
```

2. Open [Atlas](https://cloud.mongodb.com/) in a private browser window.
3. Enter `terraform output -raw alice_email` from this example as the username.
4. Complete the Okta sign-in with `terraform output -raw alice_password`.

Atlas routes the email domain to your workforce IdP, then grants org access from the role mapping in `federated-workforce-org`.

## Feedback or Help

- If you have any feedback or trouble, please open a GitHub Issue.

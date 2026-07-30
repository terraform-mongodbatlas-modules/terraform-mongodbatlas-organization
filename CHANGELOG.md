## (Unreleased)

## 0.2.0 (July 30, 2026)

BREAKING CHANGES:

* output/org_managed_credential: Renames `public_key`, `private_key`, `client_id`, and `client_secret` to a single sensitive object output `org_managed_credential` with those four fields. Use only for bootstrap; update references from `module.<name>.public_key` to `module.<name>.org_managed_credential.public_key` (and likewise for the other three fields). ([#47](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization/pull/47))

NOTES:

* provider/mongodbatlas: Requires minimum version 2.15 to avoid a Service Account issue in the paying org when creating a new org ([#50](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization/pull/50))
* terraform: Requires minimum version 1.10 to align with the MongoDB Atlas provider compatibility matrix ([#44](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization/pull/44))

ENHANCEMENTS:

* example/federated_workforce_org: Adds org_config and role mapping example for existing federated orgs ([#29](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization/pull/29))
* example/federation_workforce_idp_okta: Adds Okta SAML workforce IdP bootstrap example ([#29](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization/pull/29))

## 0.1.0 (March 05, 2026)
* Initial release

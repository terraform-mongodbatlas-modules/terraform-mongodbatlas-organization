variable "okta_org_name" {
  description = "Okta org subdomain (for example integrator-7930367 from integrator-7930367.okta.com)."
  type        = string
}

variable "okta_api_token" {
  description = "Okta API token. Omit to use OKTA_API_TOKEN in the environment."
  type        = string
  sensitive   = true
  default     = null
}

variable "atlas_acs_url" {
  description = "Atlas Assertion Consumer Service URL from FMC IdP metadata. Leave empty for Step 1 placeholders."
  type        = string
  default     = ""
}

variable "atlas_audience" {
  description = "Atlas Audience URI from FMC IdP metadata. Leave empty for Step 1 placeholders."
  type        = string
  default     = ""
}

variable "federated_domain" {
  description = "Atlas-verified domain for SAML test users."
  type        = string
}

variable "alice_email" {
  description = "Synthetic federated test user primary email and username."
  type        = string
  default     = null
}

variable "create_alice_user" {
  description = "Create the lab Okta test user with a random password."
  type        = bool
  default     = false
}

variable "atlas_org_owners_group" {
  description = "Okta group name emitted in memberOf for downstream role mappings."
  type        = string
  default     = "atlas-org-owners"
}

variable "org_id" {
  description = "24-hex lab Atlas org ID. Terraform looks up federation_settings_id from this org when enable_atlas_federation is true."
  type        = string
  default     = ""
}

variable "enable_atlas_federation" {
  description = "Manage Atlas workforce IdP after FMC bootstrap and terraform import."
  type        = bool
  default     = false

  validation {
    condition = !var.enable_atlas_federation || (
      length(var.org_id) > 0 && length(var.workforce_idp_id) > 0
    )
    error_message = "org_id and workforce_idp_id are required when enable_atlas_federation is true."
  }
}

variable "workforce_idp_id" {
  description = "24-hex Atlas IdP id from FMC (import id suffix). Required when enable_atlas_federation is true."
  type        = string
  default     = ""
}

variable "atlas_idp_name" {
  description = "Configuration name of the SAML IdP in FMC."
  type        = string
  default     = "Okta Lab"
}

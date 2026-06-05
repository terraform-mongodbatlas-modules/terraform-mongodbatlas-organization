variable "federation_settings_id" {
  type        = string
  description = "Federation settings ID shared by the paying org and child org."

  validation {
    condition     = length(var.federation_settings_id) > 0
    error_message = "federation_settings_id must not be empty."
  }
}

variable "okta_idp_id" {
  type        = string
  description = "Atlas IdP identifier used in import IDs and mongodbatlas_federated_settings_org_config.identity_provider_id."

  validation {
    condition     = length(var.okta_idp_id) > 0
    error_message = "okta_idp_id must not be empty."
  }
}

variable "idp_id" {
  type        = string
  description = "Atlas IdP ID for mongodbatlas_federated_settings_org_config.data_access_identity_provider_ids."
}

variable "org_owner_id" {
  type        = string
  description = "Atlas user ID of the child organization owner."
}

variable "org_name" {
  type        = string
  description = "Name of the child organization to create."
}

variable "org_description" {
  type        = string
  default     = null
  description = "Optional description for the child organization."
}

variable "external_group_name" {
  type        = string
  description = "IdP group ID or name mapped to ORG_OWNER on the child org."
}

variable "post_auth_role_grants" {
  type        = list(string)
  default     = ["ORG_MEMBER"]
  description = "Default organization roles granted to federated users after authentication."
}

variable "idp" {
  type = object({
    name                         = string
    idp_type                     = string
    status                       = string
    associated_domains           = list(string)
    issuer_uri                   = string
    protocol                     = string
    request_binding              = string
    response_signature_algorithm = string
    sso_url                      = string
    sso_debug_enabled            = optional(bool, false)
  })
  description = "Imported identity provider configuration. Must match the IdP already present in federation settings."

  validation {
    condition     = length(var.idp.associated_domains) > 0
    error_message = "idp.associated_domains must contain at least one verified domain."
  }
}

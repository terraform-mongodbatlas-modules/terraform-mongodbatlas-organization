variable "org_id" {
  description = "MongoDB Atlas organization ID"
  type        = string
}

variable "service_account_name" {
  description = "Service account name (not required to be unique)"
  type        = string
  default     = "example-sa-secret-rotation"
}

variable "service_account_roles" {
  description = "Organization roles for the service account"
  type        = set(string)
  default     = ["ORG_OWNER"]
}

variable "secret_expires_after_hours" {
  description = "Secret TTL in hours (org policy may enforce min/max)"
  type        = number
  default     = 2160 # 90 days; use a smaller value only in non-production orgs
}

variable "rotation_hours" {
  description = "Hours between scheduled replaces per slot; secret_2 is offset by half this period on first bootstrap (see rotation.tf)"
  type        = number
  default     = 2160

  validation {
    condition     = var.rotation_hours >= 2
    error_message = "rotation_hours must be at least 2 so the half-period offset is meaningful."
  }
}

variable "manual_changes_secret_1" {
  description = "Arbitrary map; change any value and apply to replace secret_1 (time_rotating.phase_a triggers)."
  type        = map(string)
  default     = {}
}

variable "manual_changes_secret_2" {
  description = "Arbitrary map; change any value and apply to replace secret_2 (time_rotating.phase_b triggers)."
  type        = map(string)
  default     = {}
}

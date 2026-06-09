resource "okta_policy_mfa" "atlas_lab_enrollment" {
  name            = "Atlas lab password-only enrollment"
  status          = "ACTIVE"
  is_oie          = true
  priority        = 1
  groups_included = [okta_group.atlas_org_owners.id]

  okta_password = { enroll = "REQUIRED" }
  okta_email    = { enroll = "OPTIONAL" }
  okta_verify   = { enroll = "NOT_ALLOWED" }
  okta_sms      = { enroll = "NOT_ALLOWED" }
  okta_call     = { enroll = "NOT_ALLOWED" }
}

resource "okta_policy_rule_mfa" "atlas_lab_enrollment" {
  name      = "Atlas lab enrollment rule"
  policy_id = okta_policy_mfa.atlas_lab_enrollment.id
  status    = "ACTIVE"
  enroll    = "LOGIN"
  priority  = 1
}

resource "okta_policy_signon" "atlas_lab_session" {
  name            = "Atlas lab global session"
  status          = "ACTIVE"
  priority        = 1
  groups_included = [okta_group.atlas_org_owners.id]
}

resource "okta_policy_rule_signon" "atlas_lab_session" {
  name           = "Atlas lab session rule"
  policy_id      = okta_policy_signon.atlas_lab_session.id
  status         = "ACTIVE"
  access         = "ALLOW"
  mfa_required   = false
  primary_factor = "PASSWORD_IDP_ANY_FACTOR"
  priority       = 1
}

resource "okta_app_signon_policy" "atlas_lab" {
  name        = "MongoDB Atlas Lab 1FA"
  description = "Password-only app sign-in for atlas-org-owners"
}

resource "okta_app_signon_policy_rule" "atlas_lab_owners_1fa" {
  name            = "Atlas org owners 1FA"
  policy_id       = okta_app_signon_policy.atlas_lab.id
  status          = "ACTIVE"
  access          = "ALLOW"
  factor_mode     = "1FA"
  groups_included = [okta_group.atlas_org_owners.id]
  priority        = 1
}

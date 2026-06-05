import {
  to = mongodbatlas_federated_settings_identity_provider.idp
  id = "${var.federation_settings_id}-${var.okta_idp_id}"
}

import {
  to       = mongodbatlas_federated_settings_org_config.this
  id       = "${var.federation_settings_id}-${module.atlas_org.org_id}"
  provider = mongodbatlas.child_org
}

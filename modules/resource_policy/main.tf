resource "mongodbatlas_resource_policy" "block_wildcard_ip" {
  count = var.block_wildcard_ip ? 1 : 0

  org_id = var.org_id
  name   = "block-wildcard-ip"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"project.ipAccessList.modify",
          resource
        )
        when { context.project.ipAccessList.contains(ip("0.0.0.0/0")) };
      EOF
    }
  ]
}

resource "mongodbatlas_resource_policy" "require_maintenance_window" {
  count = var.require_maintenance_window ? 1 : 0

  org_id = var.org_id
  name   = "require-maintenance-window"

  policies = [
    {
      body = <<-EOF
        forbid (
          principal,
          action == ResourcePolicy::Action::"cluster.modify",
          resource
        )
        when { context.project.hasDefinedMaintenanceWindow == false };
      EOF
    }
  ]
}

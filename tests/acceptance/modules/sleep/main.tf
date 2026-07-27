variable "destroy_duration" {
  description = "How long to wait during terraform test teardown before destroying earlier run blocks."
  type        = string
  default     = "30s"
}

resource "time_sleep" "before_teardown" {
  destroy_duration = var.destroy_duration
  triggers = {
    dummy = "value"
  }
}

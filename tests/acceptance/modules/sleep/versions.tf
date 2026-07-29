terraform {
  required_version = ">= 1.10"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

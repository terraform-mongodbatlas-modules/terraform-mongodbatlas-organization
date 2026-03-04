# MongoDB Atlas Organization Terraform Examples

The following are examples for managing MongoDB Atlas organizations with Terraform. Each example has a specific use case, choose the one that best fits your needs.

## Quick Start Guide

| Use Case | Example | Description |
|----------|---------|-------------|
| **Manage existing organization** | [`existing-org/`](./existing-org/) | Applies resource policies to an organization that already exists in MongoDB Atlas. |
| **Create new organization (single apply)** | [`new-org-single-apply/`](./new-org-single-apply/) | Creates a new organization and apply policies in a single `terraform apply` command. |
| **Create new organization (two-step)** | [`new-org-two-step/`](./new-org-two-step/) | Creates a new organization and apply policies in separate steps. Note: Use this when you cannot use the single-apply workflow. |
| **Import existing organization** | [`import/`](./import/) | Import an already-existing MongoDB Atlas organization into your Terraform state. |

## Prerequisites

All examples require:

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
2. A [MongoDB Atlas Account](https://www.mongodb.com/products/integrations/hashicorp-terraform)
3. Configured [authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) via environment variables or provider configuration

<!-- This file is used to generate the examples/README.md files -->
# {{ .NAME }}

## Prerequisites

1. Install [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.9).
2. Sign up for a [MongoDB Atlas Account](https://www.mongodb.com/products/integrations/hashicorp-terraform).
3. Configure [authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) via environment variables or provider configuration.

## Commands

```sh
terraform init
# configure your variables in a `terraform.tfvars` file or pass them via -var flags
{{ .PRODUCTION_CONSIDERATIONS_COMMENT }}
terraform apply
# cleanup
terraform destroy
```

{{ .CODE_SNIPPET }}
{{ .PRODUCTION_CONSIDERATIONS }}

## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

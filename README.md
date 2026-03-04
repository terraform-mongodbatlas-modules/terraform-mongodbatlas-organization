# MongoDB Atlas Organization Terraform Module

## Overview

This Terraform module simplifies the management of MongoDB Atlas organizations. It provides a streamlined way to create and configure organization resources, including teams, projects, and roles, using infrastructure-as-code principles.

The module is designed to help DevOps engineers and cloud architects automate MongoDB Atlas organization setup and management within their Terraform workflows.


## Usage 

```hcl
module "mongodb_atlas_org" {
    source = "./modules/organization"

    org_name = "my-organization"
    api_key  = var.mongodb_atlas_api_key
    
    teams = {
        platform = {
            name        = "Platform Team"
            description = "Infrastructure and platform team"
        }
    }
}
```

To use this module:

1. Initialize Terraform:
     ```bash
     terraform init
     ```

2. Plan your changes:
     ```bash
     terraform plan
     ```

3. Apply the configuration:
     ```bash
     terraform apply
     ```

For detailed examples, see the `examples/` directory.

## Resources

This module manages the following MongoDB Atlas resources:

- **Organizations**: Create and configure MongoDB Atlas organizations
- **Teams**: Define teams within the organization with specific permissions
- **Projects**: Create projects and assign teams to manage resources
- **Organization Roles**: Configure custom roles for organization-level access control
- **API Keys**: Generate and manage API credentials for programmatic access
- **IP Whitelist**: Manage IP access restrictions at the organization level

## Considerations 

### API Key Security
Ensure MongoDB Atlas API keys are stored securely using Terraform variables or a secrets management system. Never commit API credentials to version control.

### Permissions and Access Control
Verify that your MongoDB Atlas organization has the necessary permissions to create teams, projects, and roles. Some operations may require Organization Owner privileges.

### API Rate Limiting
Be aware of MongoDB Atlas API rate limits when managing large numbers of resources. Consider implementing delays between operations if needed.

### State Management
Store your Terraform state file securely, as it contains sensitive information about your MongoDB Atlas organization configuration.

### Existing Resources
If importing existing MongoDB Atlas organizations, use `terraform import` to avoid duplicate resource creation and maintain consistency with your infrastructure code.

### Regional Considerations
MongoDB Atlas organization and project settings may have regional implications. Review MongoDB's documentation for region-specific features and limitations before deployment.

## License


<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_INPUTS_RAW -->
<!-- END_TF_INPUTS_RAW -->
<!-- END_TF_DOCS -->

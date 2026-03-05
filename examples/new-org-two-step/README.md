# Create Organization with Policies (Two-Step)

Two-step workflow for creating a new Atlas organization and applying resource policies when you cannot use the [single-apply](../new-org-single-apply/) workflow.

## Step 1 — Create the Organization

Run from [`step1/`](./step1/). Uses paying org credentials to create the organization and outputs a PAK (public/private key) for the new org.

```sh
cd step1
terraform init
# configure org_name and org_owner_id in terraform.tfvars or via -var flags
terraform apply
```

## Step 2 — Apply Resource Policies

Run from [`step2/`](./step2/). Configure the provider with the new org credentials from step 1 outputs, then apply resource policies using the `existing` submodule.

```sh
# export credentials from step 1 for the new org provider
export MONGODB_ATLAS_PUBLIC_KEY=$(cd step1 && terraform output -raw public_key)
export MONGODB_ATLAS_PRIVATE_KEY=$(cd step1 && terraform output -raw private_key)

cd step2
terraform init
terraform apply -var="org_id=$(cd ../step1 && terraform output -raw org_id)"
```

# Test Guide

This guide covers the testing infrastructure for the terraform-mongodbatlas-organization module.

## Test Types

| Type | Purpose | CI Trigger | Credentials Required |
|------|---------|-----------|---------------------|
| Unit plan tests | Validate plan-time behavior with mock providers | Every PR (`code-health.yml`) | No |
| Plan snapshot tests | Detect unintended plan regressions | Every PR (`code-health.yml`) | Yes (plan-only) |
| Acceptance tests | Apply and destroy real infrastructure | Weekly / manual (`pre-release-tests.yml`) | Yes (full) |

## Authentication Setup

```bash
export MONGODB_ATLAS_CLIENT_ID="..."
export MONGODB_ATLAS_CLIENT_SECRET="..."
export MONGODB_ATLAS_ORG_ID="..."                   # required for plan snapshot and import tests
export MONGODB_ATLAS_ORG_NAME="..."                  # required for import test (must match org_id's org)
export MONGODB_ATLAS_ORG_OWNER_ID="..."             # required for acceptance tests (org creation)
```

See [MongoDB Atlas Provider Authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) for details.

## Prerequisites

```bash
brew install just terraform uv
```

## Unit Plan Tests

Located in `tests/*.tftest.hcl`. These use `mock_provider` blocks and run without credentials.

```bash
just unit-plan-tests
```

## Plan Snapshot Tests

Located in `tests/workspace_org_examples/`. The workspace manually declares module blocks calling `modules/create` and `modules/existing` with various configurations. Plan output is compared against committed snapshots in `plan_snapshots/`.

### Architecture

The `new-org-*` examples declare aliased providers (`mongodbatlas.org_creator`), which Terraform forbids in child modules called by the gen framework. To work around this, the workspace `main.tf` declares module blocks directly instead of relying on auto-generation.

### Running locally

```bash
# Generate dev.tfvars (reads from MONGODB_ATLAS_ORG_ID env var)
just dev-vars-org

# First run -- generates baseline snapshots
just plan-snapshot-test-org --force-regen

# Subsequent runs -- compares against committed snapshots
just plan-snapshot-test-org
```

### Updating snapshots

When module changes intentionally alter the plan output:

```bash
just plan-snapshot-test-org --force-regen
```

Review the diffs in `tests/workspace_org_examples/plan_snapshots/` and commit the updated files.

## Acceptance Tests (Apply/Destroy)

These tests apply real infrastructure and then destroy it. They require `MONGODB_ATLAS_ORG_OWNER_ID` and `MONGODB_ATLAS_ORG_NAME` in addition to credentials.

```bash
# Generate dev.tfvars
just dev-vars-org

# Apply
just apply-examples-org --auto-approve

# Check outputs
just check-outputs-org

# Remove imported org from state (prevent destroying pre-existing org)
terraform -chdir=tests/workspace_org_examples state rm module.ex_import || true

# Destroy
just destroy-examples-org --auto-approve
```

## Workspace Examples

The workspace at `tests/workspace_org_examples/` covers these scenarios:

| Module block | Source | Description |
|-------------|--------|-------------|
| `ex_create_with_pak` | `modules/create` | Create org with programmatic API key |
| `ex_create_with_policies` | `modules/create` | Create org with PAK + resource policies |
| `ex_import` | `modules/create` | Import existing org via `import` block |
| `ex_existing_org` | `modules/existing` | Manage policies on an existing org |

## CI Workflows

- **`code-health.yml`** -- Runs plan snapshot tests on every PR.
- **`pre-release-tests.yml`** -- Runs acceptance tests weekly (Monday 06:00 UTC) and on manual dispatch. Removes imported org from state before destroy to avoid deleting pre-existing resources.

## CI Required Secrets

| Secret | Description |
|--------|-------------|
| `MONGODB_ATLAS_CLIENT_ID` | Service account client ID |
| `MONGODB_ATLAS_CLIENT_SECRET` | Service account client secret |
| `MONGODB_ATLAS_ORG_ID` | Atlas organization ID (for existing-org and import tests) |
| `MONGODB_ATLAS_ORG_NAME` | Atlas organization name (must match `ORG_ID`) |
| `MONGODB_ATLAS_ORG_OWNER_ID` | Atlas user ID (for org creation in acceptance tests) |

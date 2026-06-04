# Service Account Secret Rotation (Two-Secret Pattern)

Standalone example for brownfield service account credential rotation: `mongodbatlas_service_account` plus two `mongodbatlas_service_account_secret` resources. This mirrors the planned `modules/service_account_rotation/` submodule pattern; it does not call the org module yet.

Implements the [Service Account Secret Rotation](https://github.com/mongodb/terraform-provider-mongodbatlas/blob/master/docs/guides/service-account-secret-rotation.md) guide with:

- **Import block** for the bootstrap secret (`secret_1`) on the second apply (after targeted bootstrap)
- **Scheduled alternation:** two offset [`time_rotating`](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) clocks ([`rfc3339`](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating#rfc3339-1) staggered by half `rotation_hours` on bootstrap) driving `replace_triggered_by` via [`time_static`](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) ([provider-time#118](https://github.com/hashicorp/terraform-provider-time/issues/118))
- **Manual rotation:** each `time_rotating` also sets `triggers = var.manual_changes_secret_*`; change the map and `terraform apply` to replace that slot outside the calendar
- **Active secret:** `current_credentials` picks the slot with the latest `expires_at` (from managed secret resources)

`force_renew` on the secret resource is not in the provider yet; bump `manual_changes_secret_*` or adjust `rotation_hours` / CI schedule.

Greenfield orgs with embedded SA rotation should use `modules/create/` once provider rotation fields ship; use this example for existing orgs or standalone service accounts.

## Prerequisites

1. Install [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.9).
2. Sign up for a [MongoDB Atlas Account](https://www.mongodb.com/products/integrations/hashicorp-terraform).
3. Configure [authentication](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication) via environment variables or provider configuration.
4. An `org_id` where you may create a test service account.
5. Scheduled rotation requires **repeated** `terraform apply` (for example CI cron); `time_rotating` only advances when Terraform runs.
6. Run apply on an interval **shorter than** `rotation_hours / 2`. If CI waits longer than that, both slot boundaries can pass before the next apply and **both secrets may replace in one run**, which removes overlap.

## Commands

```sh
cd examples/sa-secret-rotation
cp terraform.tfvars.example terraform.tfvars
# edit org_id
terraform init
```

Bootstrap needs **two applies**. The `import` block for `secret_1` uses `client_id` and `secrets[0].secret_id` from the service account, which only exist after apply, so a single `terraform apply` fails at plan time with `Invalid import id argument`.

**Step 1 — create the service account only** (targeted apply):

```sh
terraform apply -target=mongodbatlas_service_account.this
```

That is enough for step 2 to plan the `import` block: `client_id` and `secrets[0].secret_id` come from state. You do not need to target `secret_2` or the `time_*` resources here; a normal apply creates them once the SA exists.

**Step 2 — everything else** (normal apply):

```sh
terraform apply
```

Step 2 should import `mongodbatlas_service_account_secret.secret_1`, create `secret_2`, and add rotation clocks.

Confirm a clean plan:

```sh
terraform plan
```

Read the active credential (uses latest `expires_at`):

```sh
terraform output -json current_credentials
terraform output rotation_schedule
terraform output rotation_triggers
```

Cleanup:

```sh
terraform destroy
```

## How scheduled alternation works

| Slot | `replace_triggered_by` | Clock | Manual trigger |
| --- | --- | --- | --- |
| `secret_1` | `time_static.phase_a` | `time_rotating.phase_a` (`rotation_hours`) | `manual_changes_secret_1` |
| `secret_2` | `time_static.phase_b` | `time_rotating.phase_b` (half-period offset on bootstrap, then `rotation_hours`) | `manual_changes_secret_2` |

When `phase_a` fires, only `secret_1` replaces. `phase_b` uses the same `rotation_hours` period, but its clock starts from an initial timestamp shifted by half a period (`rotation_hours / 2`) so the first `secret_2` replace lands midway between the first two `secret_1` replaces.

### Worked example (90-day TTL, 45-day rotation)

Set a 90-day Atlas secret lifetime and a 45-day replace cadence (values in hours):

```hcl
secret_expires_after_hours = 2160 # 90 days
rotation_hours             = 1080 # 45 days
```

Assume **day 0** is when step 2 finishes: both `secret_1` and `secret_2` exist and each has `expires_at` about 90 days out. CI runs `terraform apply` whenever a rotation boundary has passed.

**Apply cadence:** With `rotation_hours = 1080` (45 days), run apply at least every **22.5 days** (`rotation_hours / 2`). A monthly job can miss the window between day 45 and day 67.5 and plan replaces for **both** slots in one apply.

**Replace schedule** (calendar boundaries; apply must run after each day):

| Day (approx.) | Slot that replaces | Why |
| --- | --- | --- |
| 45 | `secret_1` | First `phase_a` period (`rotation_hours` from day 0) |
| 67.5 | `secret_2` | First `phase_b` period: initial anchor at day 22.5, then `rotation_hours` (45 days) |
| 90 | `secret_1` | Second `phase_a` period |
| 112.5 | `secret_2` | Second `phase_b` period (45 days after day 67.5) |
| 135 | `secret_1` | Third `phase_a` period |

The 22.5-day value is **not** a replace on its own. It is added only to `phase_b`'s initial `rfc3339` while the bootstrap secret is being adopted; every `phase_b` rotation still uses `rotation_hours = 45`. First `secret_2` replace is therefore 22.5 + 45 = **67.5** days, then every 45 days after that.

So with 45-day rotation and a 90-day TTL you get: `secret_1` at 45 and 90 days, `secret_2` at about 67 days, then the pattern continues.

**`expires_at` after each replace** (each new secret gets another 90-day TTL from Atlas):

| After replace on day | `secret_1` expires (approx.) | `secret_2` expires (approx.) | `current_credentials` slot |
| --- | --- | --- | --- |
| 0 (initial) | ~90 | >90 (slightly later) | `secret_2` (`secret_1` is the bootstrap secret from service account create; `secret_2` is created on step 2 and has the later `expires_at`) |
| 45 (`secret_1`) | 135 | 90 | `secret_1` (later `expires_at`) |
| 67.5 (`secret_2`) | 135 | 157.5 | `secret_2` |
| 90 (`secret_1`) | 180 | 157.5 | `secret_1` |

`current_credentials` always selects the slot with the **latest** `expires_at`. The slot that just rotated receives a fresh 90-day lifetime; the other slot is older and usually expires sooner. CI therefore does not read the credential that is about to age out, which avoids pushing a value from a secret you are imminently replacing and reduces the risk of deleting a secret that downstream jobs still use.

Example on **day 44** (before the first `secret_1` rotate): `current_credentials` is still `secret_2` because its `expires_at` remains later than the bootstrap `secret_1`. After **day 45** apply, `secret_1` has `expires_at` around day 135 and becomes the active output while `secret_2` remains valid until day 67.5.

Keep `secret_expires_after_hours` at least as large as `rotation_hours` times the number of applies between slot replaces (here 90 days TTL vs 45 days between replaces on a given slot) so the non-rotated slot remains valid for overlap.

### Rotation clock coupling

Do **not** set `time_rotating.phase_b.rfc3339 = time_rotating.phase_a.rfc3339` (or `timeadd` of it) without a one-time bootstrap offset. Every time `phase_a` rotates, `phase_a.rfc3339` changes, which would re-anchor `phase_b` and tend to trigger `secret_2` on the **next** apply (back-to-back replaces, no overlap).

This example sets `phase_b.rfc3339` only while the service account still has a single bootstrap secret (`secrets_more_than1` is false), using `timeadd(time_static.first_time_apply.rfc3339, rotation_hours/2)` as the **starting anchor** only. After `secret_2` exists, `phase_b` keeps `rotation_hours` and no longer overrides `rfc3339`; the half-period shift is not re-applied on later applies.

### Why both `time_rotating` and `time_static`?

- **`time_rotating`** is the schedule. It stores a base timestamp and a rotation boundary ([`rfc3339` / `rotation_rfc3339`](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating#rfc3339-1)). When that boundary passes and you run `terraform apply`, the clock rolls forward.
- **`time_static`** is the adapter for `replace_triggered_by`. Secret resources reference `time_static.phase_a` / `phase_b`, not `time_rotating` directly.

Do not point `replace_triggered_by` at `time_rotating` alone. After the rotation time passes, the time provider often drops the instance from state and the next plan shows a **create**, not a **replace**, so downstream secrets may not replace ([#118](https://github.com/hashicorp/terraform-provider-time/issues/118)). Wiring `time_static` with `rfc3339 = time_rotating.*.rfc3339` turns the roll-forward into an **update** on a stable address, which Core treats as a valid replace trigger.

## Manual rotation with `manual_changes_secret_*`

Each `time_rotating` resource also accepts [`triggers`](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating#triggers). When any key or value in the map changes, the clock rolls and the linked secret replaces on the next apply (in addition to the calendar).

```hcl
# terraform.tfvars — replace secret_1 only
manual_changes_secret_1 = { rotation_id = "2026-06-04" }
manual_changes_secret_2 = {}
```

```sh
terraform apply
terraform output -json current_credentials
```

Alternate slots so one secret stays valid during overlap.

## Tuning

- **CI apply interval:** Shorter than `rotation_hours / 2` so only one slot replaces per apply (see worked example).
- **`rotation_hours`:** How often each slot is eligible for calendar replace (default 2160). Use a smaller value only in non-production orgs.
- **`secret_expires_after_hours`:** Atlas TTL (default 2160). Should be long enough that both secrets stay valid between applies; org policy may enforce min/max.
- **`manual_changes_secret_*`:** Any string map; CI can set `rotation_id` to a build ID, date, or monotonic counter.
- **Disable scheduled replace:** Remove `replace_triggered_by` from both secrets in `main.tf` (Terraform requires static lifecycle lists; there is no bool toggle).

## Provider alias smoke test

After `current_credentials` has a non-null `client_secret`:

```hcl
provider "mongodbatlas" {
  alias         = "sa"
  client_id     = ... # from output client_id
  client_secret = ... # from current_credentials
}
```

## Code Snippet

**main.tf** (excerpt; see [rotation.tf](./rotation.tf) for clocks):

```hcl
resource "mongodbatlas_service_account_secret" "secret_1" {
  org_id    = var.org_id
  client_id = mongodbatlas_service_account.this.client_id
  lifecycle {
    replace_triggered_by = [time_static.phase_a]
  }
}
```

**rotation.tf** (excerpt):

```hcl
resource "time_rotating" "phase_a" {
  rotation_hours = var.rotation_hours
  triggers       = var.manual_changes_secret_1
}

resource "time_static" "phase_a" {
  rfc3339 = time_rotating.phase_a.rfc3339
}
```

**Additional files needed:**

- [rotation.tf](./rotation.tf)
- [variables.tf](./variables.tf)
- [outputs.tf](./outputs.tf)
- [versions.tf](./versions.tf)

## Feedback or Help

- If you have any feedback or trouble please open a Github Issue

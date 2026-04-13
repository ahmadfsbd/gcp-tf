# Terraform Environments and Workspaces

Source your OpenStack RC file before running Terraform commands, for example:

```bash
source ~/key/hgi-dev-openrc.sh
```

## Environment Layout

Each environment lives under `environments/<env>/` and must contain:

- `terraform.tfvars`

Current examples:

- `environments/dev/terraform.tfvars`
- `environments/prod/terraform.tfvars`

Workspace naming convention:

- Terraform Cloud workspace name: `gcp-tf-<env>`
- Terraform CLI workspace name (because of prefix mapping): `<env>`
- Example: select `dev` in CLI, it maps to `gcp-tf-dev` in Terraform Cloud

## Quick Start (Recommended)

Use the guarded wrapper to avoid workspace/tfvars mismatch.

Default is local run mode (best for your current setup):

```bash
./scripts/tf-env.sh <plan|apply|destroy> <env> [extra terraform args]
```

Examples:

```bash
./scripts/tf-env.sh plan dev
./scripts/tf-env.sh apply dev -auto-approve
./scripts/tf-env.sh destroy prod
```

This is the easiest and safest day-to-day workflow when Terraform Cloud workspace execution is set to Local.

## Manual Commands (No Scripts)

Use this flow if you want to understand each step.

1. Initialize and select workspace:

```bash
terraform init
terraform workspace select <env> || terraform workspace new <env>
terraform workspace show
```

2. Run Terraform with explicit var-file:

```bash
source ~/key/hgi-dev-openrc.sh
terraform plan -var-file="environments/<env>/terraform.tfvars"
terraform apply -var-file="environments/<env>/terraform.tfvars"
terraform destroy -var-file="environments/<env>/terraform.tfvars"
```

Why this local manual flow works:

- Local execution accepts `-var-file` normally.
- Your OpenStack credentials come from your shell (`source openrc.sh`).

## Remote Execution Learning Mode

If workspace execution is set to Remote in Terraform Cloud, `-var-file` is rejected.

Use wrapper remote mode:

```bash
./scripts/tf-env.sh plan <env> --run-mode remote
./scripts/tf-env.sh apply <env> --run-mode remote
```

Or manual remote flow:

```bash
terraform workspace select <env> || terraform workspace new <env>
cp environments/<env>/terraform.tfvars .tfenv.auto.tfvars
terraform plan
terraform apply
rm -f .tfenv.auto.tfvars
```

Why this remote flow is needed:

- Remote runs do not accept `-var-file` run variables.
- Files ending in `.auto.tfvars` are loaded automatically.

## Workspace Selection Only

If you only want to select or create the workspace:

```bash
./scripts/use-env.sh <env>
```

After selecting workspace, run with the wrapper:

```bash
./scripts/tf-env.sh plan <env>
./scripts/tf-env.sh apply <env>
./scripts/tf-env.sh destroy <env>
```

## Script Behavior

### scripts/use-env.sh

1. Validates `environments/<env>/` exists.
2. Validates `environments/<env>/terraform.tfvars` exists.
3. Runs `terraform init`.
4. Selects CLI workspace `<env>` (which maps to remote `gcp-tf-<env>`).
5. Creates workspace if missing.

Usage:

```bash
./scripts/use-env.sh <environment>
```

### scripts/tf-env.sh

1. Validates action (`plan|apply|destroy`).
2. Validates `environments/<env>/terraform.tfvars` exists.
3. Calls `scripts/use-env.sh <env>`.
4. Verifies active CLI workspace is exactly `<env>`.
5. If run mode is `local` (default): runs Terraform with `-var-file`.
6. If run mode is `remote`: creates temporary `.tfenv.auto.tfvars`, runs Terraform, then removes it.

Run mode options:

- `--run-mode local` (default)
- `--run-mode remote`

Plain explanation of "what generates auto vars":

Only in remote run mode, this line creates the temporary file:

```bash
cp "$project_root/$tfvars_path" "$project_root/$auto_tfvars_path"
```

That line creates `.tfenv.auto.tfvars` by copying your environment tfvars file.
After Terraform finishes, this line cleans it up:

```bash
trap 'rm -f "$project_root/$auto_tfvars_path"' EXIT
```

## Prerequisites

- Terraform installed
- Terraform Cloud CLI login completed once (`terraform login`)
- OpenStack credentials available from RC file (or configure `provider.tf`)

For Terraform Cloud and state-management details, see `TERRAFORM_CLOUD.md`.

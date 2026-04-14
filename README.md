# Terraform Environments (Folder-Based)

This repository uses folder-based environment isolation.

Each environment is a separate Terraform root module:

- `environments/dev/`
- `environments/prod/`

Both environment roots reuse shared modules under `modules/`.

## Why This Structure

- Clear boundary between environments.
- Separate backend/workspace per environment root.
- Lower risk of accidentally applying dev values to prod state.

## Environment Layout

Each environment folder contains its own root Terraform files:

- `main.tf`
- `variables.tf`
- `provider.tf`
- `versions.tf`
- `outputs.tf`
- `terraform.tfvars`

## Quick Start (Recommended)

1. Source OpenStack credentials:

```bash
source ~/key/hgi-dev-openrc.sh
```

2. Plan/apply directly in each environment folder:

```bash
cd environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

cd ../prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Manual Commands (No Scripts)

Run directly inside the environment folder:

```bash
cd environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform destroy -var-file=terraform.tfvars
```

For prod, use `cd environments/prod`.

## Prerequisites

- Terraform installed
- Terraform Cloud CLI login completed once (`terraform login`)
- OpenStack credentials available from RC file (or configure `provider.tf`)

For Terraform Cloud and state-management details, see `TERRAFORM_CLOUD.md`.

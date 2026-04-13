# Terraform Environments

First step: source your OpenStack RC file before running Terraform commands (for example, `source openrc.sh`).

This repository supports environment-specific deployments using tfvars files in the `environments/` directory.

## Available Environment Files

- `environments/dev.tfvars`
- `environments/prod.tfvars`

## Prerequisites

- Terraform installed
- OpenStack credentials configured (or update `provider.tf` accordingly)

## Initialize Terraform

Run once from the project root:

```bash
terraform init
```

## Plan an Environment-Specific Stack

### Dev

```bash
terraform plan -var-file="environments/dev.tfvars"
```

### Prod

```bash
terraform plan -var-file="environments/prod.tfvars"
```

## Apply an Environment-Specific Stack

### Dev

```bash
terraform apply -var-file="environments/dev.tfvars"
```

### Prod

```bash
terraform apply -var-file="environments/prod.tfvars"
```

## Destroy an Environment-Specific Stack

### Dev

```bash
terraform destroy -var-file="environments/dev.tfvars"
```

### Prod

```bash
terraform destroy -var-file="environments/prod.tfvars"
```

## Useful Tip

If you frequently work with one environment, export `TF_CLI_ARGS_plan` and `TF_CLI_ARGS_apply` with `-var-file=...` to avoid repeating the flag.

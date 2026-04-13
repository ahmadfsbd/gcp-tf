# Terraform Cloud — State Management Guide

## What is Terraform Cloud?

Terraform Cloud (HCP Terraform) is a hosted service by HashiCorp at [app.terraform.io](https://app.terraform.io).
It stores your Terraform **state files remotely** so that:

- State is never lost if your laptop/server is wiped.
- Multiple people can collaborate without overwriting each other's state.
- State is **locked** while an apply is running, preventing concurrent changes.

You do NOT need to run Terraform Cloud agents or CI/CD for this project. You can run Terraform locally; the main difference is **state is stored remotely**.

---

## Key Concepts

| Term         | Meaning                                                                 |
|--------------|-------------------------------------------------------------------------|
| Organization | Your top-level account grouping (`ahmadfsbd`). Holds all workspaces.   |
| Workspace    | Stores the state for **one environment** (e.g. dev, prod).             |
| State        | A JSON file tracking every resource Terraform manages.                 |
| State Lock   | Prevents two applies running at the same time against the same state.  |
| CLI Login    | `terraform login` stores credentials for your local Terraform CLI.      |

---

## How State is Managed Per Environment

Without remote state, Terraform stores state locally in `terraform.tfstate`.
That is risky for team usage and easy to mix up across environments.

With Terraform Cloud workspaces, each environment gets its own isolated state:

```
Organization: ahmadfsbd
├── Workspace: gcp-tf-dev      -> stores dev state
├── Workspace: gcp-tf-prod     -> stores prod state
└── Workspace: gcp-tf-staging  -> stores staging state
```

Workspace naming pattern in this repo is `gcp-tf-<env>`, selected via Terraform workspace commands.

Because backend uses `workspaces { prefix = "gcp-tf-" }`:

- Terraform Cloud workspace is `gcp-tf-<env>`
- Terraform CLI workspace command uses `<env>`

---

## One-Time Setup

### 1. Create Workspaces in Terraform Cloud

In [app.terraform.io](https://app.terraform.io):
1. Go to your org `ahmadfsbd`.
2. Click **New Workspace** → choose **CLI-driven workflow**.
3. Create workspaces using the naming pattern `gcp-tf-<env>`.

> **CLI-driven** means you still run Terraform locally — HCP just stores the state.

### 2. Authenticate Your CLI

```bash
terraform login
```

This opens your **browser** and takes you to `app.terraform.io` to confirm the login.
Once you click **Confirm and allow**, a token is automatically generated and saved to
`~/.terraform.d/credentials.tfrc.json` — you don't need to paste anything manually.

Important for OpenStack provider authentication:

- If runs execute remotely in Terraform Cloud, set OpenStack `OS_*` variables in the workspace Variables page.
- If runs execute locally, source your OpenRC file in your shell before running Terraform.

---

## Configuring This Project

Terraform Cloud backend is configured in `cloud.tf` using remote backend workspace prefix.

### `cloud.tf` (current pattern):

```hcl
terraform {
  backend "remote" {
    organization = "ahmadfsbd"

    workspaces {
      prefix = "gcp-tf-"
    }
  }
}
```

With this configuration, Terraform maps workspaces like:

- `gcp-tf-dev`
- `gcp-tf-prod`
- `gcp-tf-qa`

Example mapping:

- `terraform workspace select dev` (CLI)
- uses `gcp-tf-dev` (Terraform Cloud)

## Variable Handling with Remote Backend

With `backend "remote"`, variable behavior depends on workspace execution mode.

### 1. Local execution mode (workspace setting = Local)

- Terraform runs on your machine.
- `-var-file` works normally.
- OpenStack auth comes from your local shell (`source openrc.sh`).

### 2. Remote execution mode (workspace setting = Remote)

- Terraform runs in Terraform Cloud workers.
- Passing `-var-file` can fail with:

`Run variables are currently not supported`

Why this happens in Remote mode:

- Remote backend runs do not accept `-var-file` run variables.
- Terraform automatically loads files ending in `.auto.tfvars`.

How this repo handles Remote mode safely:

- `scripts/tf-env.sh --run-mode remote` copies `environments/<env>/terraform.tfvars` to `.tfenv.auto.tfvars`.
- Terraform plan/apply/destroy then reads those variables automatically.
- The temporary file is removed when command exits.

Exact script lines:

```bash
cp "$project_root/$tfvars_path" "$project_root/$auto_tfvars_path"
trap 'rm -f "$project_root/$auto_tfvars_path"' EXIT
```

First line creates `.tfenv.auto.tfvars` from your env tfvars file.
Second line ensures it is deleted when the command exits.

---

## Local vs Remote State Files

With this backend, the authoritative infrastructure state is in Terraform Cloud.

- Remote source of truth: workspace state in Terraform Cloud.
- Local backend metadata: `.terraform/terraform.tfstate`.
- Legacy local files like `terraform.tfstate` and `terraform.tfstate.backup` may still exist from older local-backend runs.

Important detail:

- In this remote-backend setup, `.terraform/terraform.tfstate` is mainly backend metadata and local bookkeeping.
- It is not the authoritative infrastructure state file for your resources.
- The real resource state lives in the Terraform Cloud workspace state.

If legacy local state files exist, keep them only for reference and avoid using them as active state.

Learning note:

- Switching Terraform CLI workspaces locally does not normally create state conflicts by itself.
- In this setup, local CLI workspace `dev` maps to remote Terraform Cloud workspace `gcp-tf-dev`, `prod` maps to `gcp-tf-prod`, and so on.
- The real state is separated remotely in Terraform Cloud; the main local risk is confusion, not state collision.

---

## Viewing State in the Browser

1. Go to [app.terraform.io](https://app.terraform.io).
2. Select org `ahmadfsbd`.
3. Click the workspace (e.g. `gcp-tf-dev`).
4. Click **States** tab — you can see each state version with a timestamp.

This gives you a full history of every apply and what changed.

---

## Locking and Conflict Prevention

Terraform Cloud automatically **locks** the workspace when an apply starts.
If a second person tries to apply to the same workspace, they get an error:

```
Error: Error locking state: Error acquiring the state lock
```

They must wait until the first apply finishes before running their own.

Common conflict cause is not lock contention, but running with the wrong workspace selected. The environment/workspace usage workflow is documented in `README.md`.

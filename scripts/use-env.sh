#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/use-env.sh <environment>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

env_name="$1"
cli_workspace_name="$env_name"
remote_workspace_name="gcp-tf-${env_name}"

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_dir="$project_root/environments/$env_name"

if [[ ! -d "$env_dir" ]]; then
  echo "Environment '$env_name' not found. Expected directory: $env_dir"
  exit 1
fi

if [[ ! -f "$env_dir/terraform.tfvars" ]]; then
  echo "Missing file: $env_dir/terraform.tfvars"
  exit 1
fi

terraform -chdir="$project_root" init >/dev/null

if terraform -chdir="$project_root" workspace select "$cli_workspace_name" >/dev/null 2>&1; then
  :
else
  terraform -chdir="$project_root" workspace new "$cli_workspace_name" >/dev/null
fi

echo "Selected environment: $env_name"
echo "Selected CLI workspace: $cli_workspace_name"
echo "Mapped remote workspace: $remote_workspace_name"
echo "Next: run ./scripts/tf-env.sh <plan|apply|destroy> $env_name"

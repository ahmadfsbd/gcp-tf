#!/usr/bin/env bash
set -euo pipefail

# Safe Terraform wrapper.
# Usage: ./scripts/tf-env.sh <plan|apply|destroy> <env> [--run-mode local|remote] [extra terraform args...]
# Default run mode is local.

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <plan|apply|destroy> <env> [--run-mode local|remote] [extra terraform args...]"
  exit 1
fi

action="$1"
env_name="$2"
shift 2

case "$action" in
  plan|apply|destroy)
    ;;
  *)
    echo "Invalid action '$action'. Use plan, apply, or destroy."
    exit 1
    ;;
esac

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cli_workspace_name="$env_name"
remote_workspace_name="gcp-tf-${env_name}"
tfvars_path="environments/${env_name}/terraform.tfvars"
auto_tfvars_path=".tfenv.auto.tfvars"
run_mode="${TF_ENV_RUN_MODE:-local}"

if [[ ! -f "$project_root/$tfvars_path" ]]; then
  echo "Missing file: $project_root/$tfvars_path"
  exit 1
fi

extra_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-mode)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --run-mode. Use local or remote."
        exit 1
      fi
      run_mode="$2"
      shift 2
      ;;
    --local-runs)
      run_mode="local"
      shift
      ;;
    --remote-runs)
      run_mode="remote"
      shift
      ;;
    *)
      extra_args+=("$1")
      shift
      ;;
  esac
done

case "$run_mode" in
  local|remote)
    ;;
  *)
    echo "Invalid run mode '$run_mode'. Use local or remote."
    exit 1
    ;;
esac

for arg in "${extra_args[@]}"; do
  if [[ "$arg" == -var-file* ]]; then
    echo "Do not pass -var-file to this wrapper."
    echo "The wrapper manages variables for the selected run mode."
    exit 1
  fi
done

"$project_root/scripts/use-env.sh" "$env_name"

active_workspace="$(terraform -chdir="$project_root" workspace show 2>/dev/null | tr -d '[:space:]')"
if [[ "$active_workspace" != "$cli_workspace_name" ]]; then
  echo "Workspace mismatch: expected CLI workspace '$cli_workspace_name' but got '$active_workspace'"
  exit 1
fi

echo "Using variables from: $tfvars_path"
echo "CLI workspace: $cli_workspace_name (remote: $remote_workspace_name)"
echo "Run mode: $run_mode"

if [[ "$run_mode" == "remote" ]]; then
  cp "$project_root/$tfvars_path" "$project_root/$auto_tfvars_path"
  trap 'rm -f "$project_root/$auto_tfvars_path"' EXIT
  echo "Running: terraform $action ${extra_args[*]}"
  terraform -chdir="$project_root" "$action" "${extra_args[@]}"
else
  echo "Running: terraform $action -var-file=$tfvars_path ${extra_args[*]}"
  terraform -chdir="$project_root" "$action" -var-file="$tfvars_path" "${extra_args[@]}"
fi

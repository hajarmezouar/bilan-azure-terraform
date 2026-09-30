#!/usr/bin/env bash
set -euo pipefail
: "${RUNNER_REPOSITORY:?Set RUNNER_REPOSITORY}"
: "${GH_TOKEN:?Set RUNNER_ADMIN_TOKEN}"
[[ "$RUNNER_REPOSITORY" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]
: "${TF_VAR_state_storage_account_name:?Set RUNNER_STATE_STORAGE_ACCOUNT}"
if [[ "$OPERATION" == apply ]]; then
  terraform -chdir=terraform/runner-state init -input=false -lockfile=readonly
  terraform -chdir=terraform/runner-state plan -input=false -lock-timeout=5m -out=bootstrap.tfplan
  terraform -chdir=terraform/runner-state show -no-color bootstrap.tfplan >> "$GITHUB_STEP_SUMMARY"
  terraform -chdir=terraform/runner-state apply -input=false -lock-timeout=5m bootstrap.tfplan
fi
# Azure RBAC data-plane permissions may need a few minutes to propagate.
initialized=false
for attempt in $(seq 1 20); do
  if terraform -chdir=terraform/runner init -input=false -lockfile=readonly \
    -backend-config="resource_group_name=$TF_VAR_resource_group_name" \
    -backend-config="storage_account_name=$TF_VAR_state_storage_account_name" \
    -backend-config='container_name=tfstate' \
    -backend-config='key=runner/terraform.tfstate' \
    -backend-config='use_azuread_auth=true' \
    -backend-config='use_oidc=true'; then
    initialized=true
    break
  fi
  sleep 15
done
[[ "$initialized" == true ]]
terraform -chdir=terraform/runner validate
args=()
if [[ "$OPERATION" == destroy ]]; then
  [[ "$CONFIRMATION" == destroy-runner ]]
  # Disable backend routing first; refuse to remove a busy runner.
  busy=$(gh api --paginate "repos/$RUNNER_REPOSITORY/actions/runners" --jq '.runners[] | select(.name=="quiz-ci-runner") | .busy')
  if [[ "$busy" == *true* ]]; then echo 'Runner is busy; retry after its job finishes.' >&2; exit 1; fi
  args=(-destroy)
fi
terraform -chdir=terraform/runner plan -input=false -lock-timeout=5m "${args[@]}" -out=runner.tfplan
terraform -chdir=terraform/runner show -no-color runner.tfplan >> "$GITHUB_STEP_SUMMARY"
terraform -chdir=terraform/runner apply -input=false -lock-timeout=5m runner.tfplan
if [[ "$OPERATION" == destroy ]]; then
  # Delete only the named registration, after successful VM destruction.
  ids=$(gh api --paginate "repos/$RUNNER_REPOSITORY/actions/runners" --jq '.runners[] | select(.name=="quiz-ci-runner") | .id')
  for id in $ids; do gh api --method DELETE "repos/$RUNNER_REPOSITORY/actions/runners/$id"; done
fi

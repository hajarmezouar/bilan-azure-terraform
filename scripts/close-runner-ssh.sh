#!/usr/bin/env bash
set -euo pipefail
# A list failure must fail the cleanup rather than masquerade as an absent NSG.
count=$(az network nsg list -g "$TF_VAR_resource_group_name" --query "length([?name=='${NSG_NAME}'])" -o tsv)
if [[ "$count" == 0 ]]; then exit 0; fi
count=$(az network nsg rule list -g "$TF_VAR_resource_group_name" --nsg-name "$NSG_NAME" --query "length([?name=='ssh-ci-temporary'])" -o tsv)
if [[ "$count" != 0 ]]; then
  az network nsg rule delete -g "$TF_VAR_resource_group_name" --nsg-name "$NSG_NAME" -n ssh-ci-temporary
fi
echo 'Temporary CI SSH rule absent.' >> "$GITHUB_STEP_SUMMARY"

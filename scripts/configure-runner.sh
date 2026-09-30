#!/usr/bin/env bash
set -euo pipefail
umask 077
: "${RUNNER_SSH_PRIVATE_KEY:?Set RUNNER_SSH_PRIVATE_KEY}"
export ANSIBLE_HOST_KEY_CHECKING=True
export ANSIBLE_NOCOLOR=1
export ANSIBLE_ROLES_PATH="$GITHUB_WORKSPACE/ansible/roles"
export VM_IP
VM_IP=$(terraform -chdir=terraform/runner output -raw public_ip)
printf '%s\n' "$RUNNER_SSH_PRIVATE_KEY" > "$RUNNER_TEMP/runner-key"
unset RUNNER_SSH_PRIVATE_KEY
# Obtain the host public key over authenticated Azure API, not untrusted ssh-keyscan.
az vm run-command invoke -g "$TF_VAR_resource_group_name" -n quiz-ci-runner \
  --command-id RunShellScript --scripts 'cat /etc/ssh/ssh_host_ed25519_key.pub' \
  --query 'value[0].message' -o tsv > "$RUNNER_TEMP/host-key-response"
awk -v ip="$VM_IP" '$1 == "ssh-ed25519" {print ip, $1, $2}' \
  "$RUNNER_TEMP/host-key-response" > "$RUNNER_TEMP/runner-known-hosts"
test -s "$RUNNER_TEMP/runner-known-hosts"
export CI_IP
CI_IP=$(curl --fail --silent --show-error --retry 3 https://api.ipify.org)
python3 -c 'import ipaddress,os; ipaddress.IPv4Address(os.environ["CI_IP"])'
az network nsg rule create -g "$TF_VAR_resource_group_name" --nsg-name "$NSG_NAME" \
  -n ssh-ci-temporary --priority 110 --access Allow --direction Inbound --protocol Tcp \
  --source-address-prefixes "$CI_IP/32" --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 22 -o none
trap 'bash scripts/close-runner-ssh.sh' EXIT
python3 - <<'PY'
import json, os
from pathlib import Path
t = os.environ['RUNNER_TEMP']
inventory = {'runners': {'hosts': {'runner': {
    'ansible_host': os.environ['VM_IP'], 'ansible_user': 'azureadmin',
    'ansible_ssh_private_key_file': t + '/runner-key',
    'ansible_ssh_common_args': '-o StrictHostKeyChecking=yes -o UserKnownHostsFile=' + t + '/runner-known-hosts',
    'ansible_python_interpreter': '/usr/bin/python3'}}}}
Path(t + '/runner-inventory.json').write_text(json.dumps(inventory))
PY
# Use GitHub release metadata; refuse installation without a SHA256 digest.
release=$(gh api repos/actions/runner/releases/latest)
export RUNNER_DOWNLOAD_URL RUNNER_CHECKSUM RUNNER_REGISTRATION_TOKEN
RUNNER_DOWNLOAD_URL=$(jq -er '.assets[] | select(.name | test("^actions-runner-linux-x64-.*tar.gz$")) | .browser_download_url' <<< "$release")
RUNNER_CHECKSUM=$(jq -er '.assets[] | select(.name | test("^actions-runner-linux-x64-.*tar.gz$")) | .digest | select(startswith("sha256:"))' <<< "$release")
RUNNER_REGISTRATION_TOKEN=$(gh api --method POST "repos/$RUNNER_REPOSITORY/actions/runners/registration-token" --jq .token)
echo "::add-mask::$RUNNER_REGISTRATION_TOKEN"
ansible runners -i "$RUNNER_TEMP/runner-inventory.json" -m ansible.builtin.wait_for_connection -a 'timeout=300'
ansible-playbook -i "$RUNNER_TEMP/runner-inventory.json" ansible/runner.yml
ansible-playbook -i "$RUNNER_TEMP/runner-inventory.json" ansible/runner.yml | tee "$RUNNER_TEMP/runner-second-pass.txt"
# Enforce a real second pass, rather than merely claiming idempotence.
grep -Eq 'runner[[:space:]]*:.*changed=0 .*unreachable=0 .*failed=0' "$RUNNER_TEMP/runner-second-pass.txt"
cat "$RUNNER_TEMP/runner-second-pass.txt" >> "$GITHUB_STEP_SUMMARY"
unset RUNNER_REGISTRATION_TOKEN
for attempt in $(seq 1 30); do
  online=$(gh api --paginate "repos/$RUNNER_REPOSITORY/actions/runners" --jq '.runners[] | select(.name=="quiz-ci-runner") | .status')
  if [[ "$online" == online ]]; then
    echo "Runner quiz-ci-runner online: https://github.com/$RUNNER_REPOSITORY/settings/actions/runners" >> "$GITHUB_STEP_SUMMARY"
    exit 0
  fi
  sleep 10
done
echo 'Runner did not come online.' >&2
exit 1

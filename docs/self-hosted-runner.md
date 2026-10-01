# Azure self-hosted GitHub Actions runner

## Purpose

This repository provisions an isolated Azure Linux VM and configures it as a repository-level GitHub Actions runner for `bilan-azure-backend`. Terraform owns the Azure infrastructure; Ansible installs and registers the runner. No VM, network resource or runner registration needs to be created manually in a portal.

The runner uses the labels `self-hosted`, `Linux`, `X64` and `azure-quiz`.

## Architecture and state separation

```text
GitHub Actions (hosted lifecycle job)
  |-- OIDC --> Azure managed identity
  |-- Terraform --> VNet, subnet, NSG, public IP, NIC and Linux VM
  |-- temporary SSH rule for the hosted job IP
  |-- Ansible over SSH --> Docker, Java and GitHub runner service
  `-- removes the temporary SSH rule

GitHub backend workflow
  `-- labels [self-hosted, linux, x64, azure-quiz] --> Azure runner VM
```

Runner state is independent from the application infrastructure:

- `terraform/runner-state` uses HCP Terraform workspace `azure-quiz-runner-bootstrap` to create the state storage account, private `tfstate` container and data-plane RBAC assignment;
- `terraform/runner` uses Azure Blob Storage with Azure AD/OIDC authentication and key `runner/terraform.tfstate`;
- Blob versioning and seven-day soft deletion are enabled;
- the storage account and container use `prevent_destroy` so an ordinary runner destruction cannot remove the state backend.

## GitHub configuration

Configure these variables on the Terraform repository's `nonprod` environment:

| Variable | Purpose |
|---|---|
| `AZURE_CLIENT_ID` | Client ID of the OIDC-federated Terraform identity |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription |
| `RUNNER_REPOSITORY` | Repository receiving the runner |
| `RUNNER_RESOURCE_GROUP` | Existing training resource group |
| `RUNNER_LOCATION` | Azure region used by runner resources |
| `RUNNER_VM_SIZE` | Policy-approved VM SKU with available capacity |
| `RUNNER_CANDIDATE_CIDR` | Candidate public IPv4 address with `/32` |
| `RUNNER_SSH_PUBLIC_KEY` | Public half of the dedicated SSH key pair |
| `RUNNER_STATE_STORAGE_ACCOUNT` | Globally unique Blob state account name |

Configure these environment secrets:

| Secret | Purpose |
|---|---|
| `TF_API_TOKEN` | Access to the bootstrap HCP Terraform workspace |
| `RUNNER_SSH_PRIVATE_KEY` | Private half of the dedicated SSH key pair |
| `RUNNER_ADMIN_TOKEN` | Fine-grained GitHub token allowed to manage repository runners |

Secret values must never be printed, committed or stored in Terraform variables files.

## Lifecycle

Provision and configure the runner:

```bash
gh workflow run runner.yml --repo hajarmezouar/bilan-azure-terraform --ref main -f operation=apply
```

Close any leftover temporary CI SSH rule without changing the VM:

```bash
gh workflow run runner.yml --repo hajarmezouar/bilan-azure-terraform --ref main -f operation=close-ssh
```

Destroy the VM and network resources only after evaluation or when the runner is no longer needed:

```bash
gh workflow run runner.yml --repo hajarmezouar/bilan-azure-terraform --ref main -f operation=destroy -f confirmation=destroy-runner
```

The destruction path refuses to continue while the named runner is busy. After successful infrastructure destruction, it removes only the `quiz-ci-runner` registration from the target repository.

## Security controls

- GitHub Actions authenticates to Azure through OIDC; there is no Azure client secret.
- Password authentication is disabled on the VM.
- The candidate SSH rule accepts only the configured `/32` address.
- A second rule temporarily permits only the current hosted workflow IP and is removed by an `always()` cleanup step and shell trap.
- The SSH host key is retrieved through authenticated Azure Run Command rather than an unauthenticated key scan.
- The runner archive URL and SHA-256 digest come from GitHub release metadata; installation refuses an archive without a digest.
- The registration token is short-lived, masked and never written to the repository.
- The runner service uses a dedicated unprivileged `github-runner` account. Docker access is granted intentionally for container builds.
- Terraform resources carry `managed_by=terraform` and workload-identifying tags.

## Idempotence and validation

The lifecycle workflow runs the same Ansible playbook twice. The second pass must report `changed=0`, `unreachable=0` and `failed=0`; otherwise the workflow fails. It then polls the GitHub API until `quiz-ci-runner` reports `online`.

Pull Requests that change runner Terraform, Ansible, lifecycle scripts or workflows run formatting, Terraform validation, shell syntax checks and an Ansible syntax check without connecting to Azure.

Useful verification commands:

```bash
gh api repos/hajarmezouar/bilan-azure-backend/actions/runners \
  --jq '.runners[] | {name,status,busy,labels:[.labels[].name]}'

az network nsg rule list \
  --resource-group hmezouarRG \
  --nsg-name nsg-quiz-ci-runner \
  --query '[].{name:name,priority:priority,source:sourceAddressPrefix,access:access}' \
  --output table
```

## Operational notes

- `SkuNotAvailable` is an Azure capacity condition. Select a policy-approved SKU through `RUNNER_VM_SIZE`, or change `RUNNER_LOCATION`; do not create the VM manually.
- Blob data-plane RBAC may take several minutes to propagate. Backend initialization retries while the role becomes effective.
- The runner archive download uses an extended timeout and retries to tolerate transient GitHub network latency.
- Application Pull Requests remain on GitHub-hosted runners so unreviewed code never executes on the persistent VM.

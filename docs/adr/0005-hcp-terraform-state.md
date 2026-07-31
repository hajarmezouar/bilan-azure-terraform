# ADR-0005: Store Terraform state in HCP Terraform

## Status

Accepted

## Context

The project requires remote state, state locking and a workflow suitable for
local Terraform commands and CI/CD. An Azure Storage backend was initially
designed, but it required a separate bootstrap configuration and an additional
Azure resource to manage before the application infrastructure.

The trainer recommended using `app.terraform.io` directly.

## Decision

Use HCP Terraform to store the non-production Terraform state and provide state
locking.

- service: `app.terraform.io`;
- organization: `hmezouar-azure-quiz`;
- workspace: `azure-quiz-nonprod`;
- workspace execution mode: local;
- authentication tokens are never committed;
- the organization and workspace names are configured in the Terraform root;
- Azure authentication uses short-lived federated credentials rather than a
  permanent client secret.

The Terraform root module will use the native `cloud` configuration. HCP
Terraform stores and locks state, while GitHub Actions executes Terraform and
authenticates to Azure through OIDC. This preserves the CI/CD design shown in
the architecture diagram.

## Alternatives considered

### Azure Storage backend

Superseded because it requires a separately bootstrapped Storage Account, Blob
container and access roles. It remains a valid Azure-native alternative.

### Local state

Rejected because it does not provide a shared source of truth or safe
collaboration and can be lost with the local workstation.

## Consequences

- no Azure Storage Account is required solely for Terraform state;
- no local bootstrap deployment is required;
- HCP Terraform account and workspace setup become prerequisites;
- state access is managed through HCP Terraform;
- plans and applies execute in GitHub Actions rather than on HCP Terraform
  workers;
- HCP credentials must be provided through `terraform login` or protected
  CI/CD configuration;
- Terraform state remains sensitive and must never be committed to Git.

# ADR-0003: Secrets and workload identities

## Status

Accepted

## Context

The application needs database, cache and storage configuration. CI/CD also
needs permission to manage Azure resources and deploy the applications.

Permanent credentials stored in GitHub, Terraform files or application source
would create a security and rotation risk.

## Decision

- store sensitive application configuration in Azure Key Vault;
- enable Azure RBAC authorization on Key Vault;
- assign a system-assigned managed identity to the backend Web App;
- grant that identity the `Key Vault Secrets User` role on the vault;
- use GitHub Actions OpenID Connect federation for Azure authentication;
- do not store an Azure client secret in GitHub;
- store and lock Terraform state in HCP Terraform;
- mark sensitive Terraform variables and outputs as `sensitive`;
- never commit `.tfvars` files containing secret values.

Database credentials may still be represented in Terraform state when Terraform
creates or configures them. The remote state backend must therefore be treated
as sensitive and protected with least-privilege access.

## Alternatives considered

### Service principal with a client secret

Rejected because the secret must be stored, rotated and protected in GitHub.
OIDC provides short-lived credentials without a permanent GitHub secret.

### Secrets in App Service settings

Plain values in application settings were rejected for long-term secret
storage. Key Vault references or managed-identity-based retrieval provide
stronger centralization and rotation.

### Secrets committed in Terraform variables

Rejected because Git history is difficult to clean and Terraform state can
retain previous values.

## Consequences

- Azure role assignments become part of the infrastructure design;
- CI/CD requires an Entra application or federated identity configuration;
- Key Vault availability and permissions become runtime dependencies;
- state-backend access must be tightly controlled and audited.

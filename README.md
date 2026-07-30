# Azure Quiz - Infrastructure

Infrastructure as Code for the non-production deployment of the Azure Quiz
application on Microsoft Azure.

The application consists of:

- an Angular frontend;
- a Java Spring Boot backend;
- PostgreSQL for persistent data;
- Azure Managed Redis for caching;
- Azure Storage for generated files;
- Azure Key Vault for secrets.

## Project status

The project is currently in the architecture and infrastructure preparation
phase. The architecture was designed before the Terraform implementation, as
required by the project specification.

No resource should be considered deployed until a successful Terraform plan,
apply and application smoke test have been recorded.

## Architecture

The selected target is **Azure managed services**:

- Azure Static Web Apps hosts the Angular frontend;
- Azure Linux Web App runs the Spring Boot container;
- the Web App uses the shared App Service Plan provided by the trainer;
- Azure Container Registry stores immutable backend images;
- PostgreSQL Flexible Server stores application data;
- Azure Managed Redis provides caching;
- Azure Storage stores exported quiz results;
- Azure Key Vault stores sensitive configuration;
- monitoring and alerting are intentionally deferred to a later iteration.

![Azure Quiz managed-services architecture](docs/architecture-managed-services.png)

The editable draw.io source is available here:

- [Managed-services architecture](docs/architecture-managed-services.drawio)

### Main application flow

```text
Internet users
      |
      | HTTPS
      v
Azure Static Web Apps
      |
      | HTTPS REST API
      v
Azure Linux Web App
      |
      +--> PostgreSQL Flexible Server
      +--> Azure Managed Redis
      +--> Storage Account
      +--> Azure Key Vault
```

## Why managed services?

Managed services were selected instead of AKS to reduce operational complexity
and complete the project within the available implementation period.

This approach still demonstrates:

- deployment of a Spring Boot container;
- automated application delivery;
- reproducible infrastructure with Terraform;
- separation between frontend, backend and data services;
- centralized logs, metrics, traces and alerts.

The trade-off is that Static Web Apps may require the backend to expose a public
HTTPS origin. This exception will be documented and mitigated with:

- HTTPS only;
- CORS restricted to the exact frontend origin;
- authentication or API access control;
- managed identity for access to Azure services;
- public access disabled on data services whenever the subscription permissions
  and selected SKUs allow it.

## Architecture decisions

The important technical decisions and rejected alternatives are documented as
Architecture Decision Records:

- [ADR-0001: Use Azure managed services](docs/adr/0001-managed-services.md)
- [ADR-0002: Network security model](docs/adr/0002-network-security.md)
- [ADR-0003: Secrets and workload identities](docs/adr/0003-secrets-and-identities.md)
- [ADR-0004: Store Terraform state in Azure Storage (superseded)](docs/adr/0004-terraform-remote-state.md)
- [ADR-0005: Store Terraform state in HCP Terraform](docs/adr/0005-hcp-terraform-state.md)

## Azure environment

The subscription, assigned resource group, permissions and trainer-provided
App Service Plan were inspected before Terraform implementation:

- [Azure environment discovery](docs/azure-environment.md)

Confirmed deployment context:

- environment: non-production;
- resource group: `hmezouarRG`;
- region: `francecentral`;
- shared Linux App Service Plan: `plan-npr-prf2026` (`S3`) in
  `rg-shared-prf2026`;
- the shared plan is referenced but is not managed by this project.
- remote state and state locking: HCP Terraform (`app.terraform.io`);
- planned HCP Terraform workspace: `azure-quiz-nonprod`.

The HCP Terraform organization and workspace must be created before the first
infrastructure deployment. The Azure subscription and tenant identifiers are
supplied through local environment variables or CI/CD configuration and are
intentionally not published in this repository.

## Secrets management

Application secrets are stored in Azure Key Vault. The backend Web App uses a
system-assigned managed identity and receives the `Key Vault Secrets User` role
on the vault. GitHub Actions uses OpenID Connect instead of a permanent Azure
client secret.

Identifiers required by CI/CD are configured outside the source code:

- `AZURE_CLIENT_ID`;
- `AZURE_TENANT_ID`;
- `AZURE_SUBSCRIPTION_ID`.

## Planned repository structure

```text
.
├── .github/
│   └── workflows/
├── docs/
│   ├── architecture-managed-services.drawio
│   ├── architecture-managed-services.png
│   └── adr/
└── terraform/
    ├── environments/
    │   └── nonprod/
    └── modules/
        ├── container-registry/
        ├── key-vault/
        ├── network/
        ├── postgresql/
        ├── redis/
        ├── static-web-app/
        ├── storage/
        └── web-app/
```

This structure will be created incrementally as the infrastructure is
implemented.

## Common tags

Every applicable resource created by this project will use consistent tags:

| Tag | Purpose |
| --- | --- |
| `owner` | Identifies the student who owns the resource |
| `environment` | Identifies the non-production environment |
| `project` | Groups resources belonging to Azure Quiz |
| `component` | Identifies the resource's application role |
| `managed-by` | Indicates that Terraform manages the resource |

The CI/CD workflows must discover shared resources using tags rather than
hard-coded resource names.

## Security principles

- No Azure or database credential is committed to Git.
- GitHub Actions authenticates to Azure using OpenID Connect.
- The backend uses a managed identity.
- Sensitive configuration is stored in Azure Key Vault.
- The frontend never connects directly to PostgreSQL, Redis, Storage or Key
  Vault.
- Terraform state and locking are managed by HCP Terraform.
- HTTPS is required for public and service-to-service communication.

## CI/CD objectives

The Terraform workflow will perform:

1. `terraform fmt -check`;
2. `terraform init`;
3. `terraform validate`;
4. IaC and secret scanning;
5. `terraform plan` on pull requests;
6. approved `terraform apply` for the non-production environment.

The application workflows will:

1. build and test the source code;
2. scan dependencies, secrets and container images;
3. build immutable artifacts;
4. deploy to the non-production environment;
5. run health checks and smoke tests;
6. notify developers when a deployment or application check fails.

## Prerequisites

Before implementing or deploying the infrastructure, confirm:

- access to the Simplon Azure subscription;
- the assigned resource group;
- the permitted Azure region;
- the required `owner` tag;
- the tags identifying the shared App Service Plan;
- the permitted PostgreSQL and Azure Managed Redis SKUs;
- permission to create Azure Container Registry;
- availability of private networking features;
- creation of the HCP Terraform organization and non-production workspace;
- the identity and permissions used by GitHub Actions.

## Local tools

The project requires:

- Terraform;
- Azure CLI;
- Git;
- Docker for testing the backend container;
- an Azure account with access to the assigned resources.

## Deployment

Deployment instructions will be added after the Terraform configuration has
been implemented and validated.

The expected workflow will be:

```text
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=environments/nonprod/terraform.tfvars
terraform apply -var-file=environments/nonprod/terraform.tfvars
```

Do not run `terraform apply` until the shared-resource identifiers, permissions,
region, quotas and remote state backend have been confirmed.

## Related repositories

The project is intentionally divided into three repositories:

- `bilan-azure-terraform` - Azure infrastructure;
- `bilan-azure-backend` - Spring Boot API;
- `bilan-azure-frontend` - Angular frontend.

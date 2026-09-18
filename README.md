# Azure Quiz — Azure Infrastructure with Terraform

This repository describes and deploys the Azure Quiz infrastructure. The project automates the delivery of an Angular frontend and a containerized Spring Boot backend using managed Azure services.

## Status

The `nonprod` environment has been successfully recreated from Terraform and validated through the application CI/CD pipelines:

- frontend: `https://app-azure-quiz-frontend-nonprod.azurewebsites.net`;
- backend API: `https://app-azure-quiz-backend-nonprod.azurewebsites.net/api/certifications`;
- backend health: `https://app-azure-quiz-backend-nonprod.azurewebsites.net/actuator/health`;
- remote Terraform state and locking are managed through HCP Terraform;
- GitHub Actions authenticates to Azure through OIDC;
- infrastructure deployment through Terraform CI/CD is operational;
- backend and frontend container deployments have been validated;
- the dedicated Terraform-managed Linux B1 App Service plan replaces the deleted trainer-managed shared plan.

## Architecture

![Azure Quiz architecture](docs/architecture-managed-services.png)

Editable source: [architecture-managed-services.drawio](docs/architecture-managed-services.drawio).

```text
User
  |
  | HTTPS
  v
Azure Linux Web App (Angular container)
  |
  | HTTPS REST API + CORS restricted to the frontend origin
  v
Azure Linux Web App (Spring Boot container)
  |
  | VNet Integration + private DNS
  +--> PostgreSQL Flexible Server (Private Endpoint)
  +--> Azure Managed Redis (Private Endpoint)
  +--> Azure Blob Storage (Private Endpoint)
  +--> Azure Key Vault (Private Endpoint)
```

Azure Container Registry stores immutable backend images identified by their Git commit SHA. GitHub Actions authenticates to Azure through OIDC, without a permanent client secret.

## Why managed services?

Azure App Service Web Apps were selected instead of AKS to reduce platform administration. There is no Kubernetes cluster, node pool, ingress controller or cluster upgrade to manage. The solution still demonstrates containerization, Infrastructure as Code, private networking, managed identities, secret management and continuous deployment.

## Deployed resources

| Component | Resource | Purpose |
|---|---|---|
| Frontend | `app-azure-quiz-frontend-nonprod` | Public Angular container hosting over HTTPS |
| Backend | `app-azure-quiz-backend-nonprod` | Spring Boot container hosting |
| Images | `acrhmezouarquiznonprod` | Private registry with admin access disabled |
| Database | `psql-hmezouar-quiz-np` | PostgreSQL 16 database `quizz` |
| Cache | `redis-hmezouar-quiz-np` | Azure Managed Redis with TLS |
| Files | `sthmezouarquiznp` | Blob container `application-files` |
| Secrets | `kv-hmezouar-quiz-np` | PostgreSQL and Redis secrets |
| Network | VNet `10.50.0.0/16` | Web App integration, private endpoints and DNS |
| Shared compute | `plan-azure-quiz-nonprod` | Terraform-managed Linux B1 plan for both Web Apps |

Non-production resources are deployed in `hmezouarRG`, primarily in `francecentral`. The nonprod App Service plan is created in that same assigned resource group, so deployment no longer depends on `rg-shared-prf2026`. The B1 tier supports the application's VNet integration and always-on setting; both apps share its compute capacity. Production uses a dedicated `rg-azure-quiz-prod` resource group and App Service plan in `francecentral`.

The Terraform deployment identity `id-github-terraform-nonprod` is bootstrapped separately and must be preserved during application cleanup. Its GitHub federation trusts the `nonprod` environment using the repository's immutable OIDC subject. It has Contributor and Role Based Access Control Administrator on `hmezouarRG` only. The application deployment identities are recreated by Terraform; update each application's GitHub `AZURE_CLIENT_ID` from the new outputs before deploying images.

## Network and identity security

- Public access is disabled for PostgreSQL, Redis, Storage and Key Vault.
- Each data service uses a Private Endpoint and a private DNS zone.
- The backend joins the VNet through App Service VNet Integration.
- Public traffic uses HTTPS, and backend CORS allows only the exact frontend URL.
- The Web App managed identity receives only the required ACR, Key Vault and Blob permissions.
- GitHub Actions uses an OIDC-federated identity with resource-scoped deployment permissions.
- No password, Azure token or registry key is committed.

## Terraform organization

```text
terraform/
├── environments/nonprod/
└── modules/
    ├── container-registry/
    ├── github-actions-identity/
    ├── key-vault/
    ├── network/
    ├── postgresql/
    ├── redis/
    ├── storage/
    └── web-app/
```

Remote state is stored in HCP Terraform organization `hmezouar-azure-quiz`, with one workspace per environment: `azure-quiz-nonprod` and `azure-quiz-prod`. HCP Terraform stores, versions and locks the state while Terraform runs from GitHub Actions or locally.

Important decisions are recorded in [`docs/adr`](docs/adr), including managed services, network security, identities and HCP Terraform state.

## Usage

Prerequisites: Terraform, Azure CLI, PowerShell 7, GNU Make and authorized Azure access.

```bash
az login
terraform login app.terraform.io

make terraform-check
make terraform-plan
# Review the saved plan before changing Azure
make terraform-apply
```

`terraform-apply` applies only the previously saved and reviewed plan. The subscription identifier is read from the active Azure CLI session and is not published in this repository.

### Terraform in GitHub Actions

The `Terraform` workflow provides the infrastructure CI/CD evidence required by the project:

1. Pull Requests run `terraform fmt -check`, `terraform init -backend=false` and `terraform validate` without Azure deployment credentials.
2. A push to `main` creates and publishes a Terraform plan but never applies it.
3. GitHub Actions authenticates to Azure with OIDC and to HCP Terraform with an API token.
4. The workflow displays the saved plan and keeps it as a short-lived workflow artifact.
5. An operator selects `nonprod` or `prod`, reviews the plan, manually runs **Actions > Terraform > Run workflow**, and enters exactly `apply-<environment>`.
6. The manual apply job downloads and applies that exact saved plan, then displays the Terraform outputs.

Configure the following GitHub **environment variables** on `nonprod`:

- `AZURE_CLIENT_ID`: client ID of the OIDC-federated Terraform deployment identity;
- `AZURE_TENANT_ID`: Microsoft Entra tenant ID;
- `AZURE_SUBSCRIPTION_ID`: target Azure subscription ID.

Configure `TF_API_TOKEN` as a GitHub **environment secret**. It is the HCP Terraform team or user token used to access organization `hmezouar-azure-quiz` and workspace `azure-quiz-nonprod`.

The Azure federated credential must trust the following GitHub subject because the deployment job uses the protected environment:

```text
repo:hajarmezouar@91194498/bilan-azure-terraform@1316992042:environment:nonprod
```

This organization uses GitHub OIDC subject customization with immutable owner and repository IDs. The federated credential must therefore use the exact subject emitted in the workflow log, not the shorter default GitHub subject format.

Protect `nonprod` with required reviewers when the GitHub plan permits it. This adds an approval gate to the explicit manual confirmation before Azure can be modified. No Azure client secret is stored in GitHub, and an ordinary push can never execute `terraform apply`.

### Manual infrastructure destruction

The `Terraform Destroy` workflow is intentionally available only through `workflow_dispatch`. It never runs on a push or Pull Request. To use it, open **Actions > Terraform Destroy > Run workflow** and enter exactly `destroy-nonprod`.

The workflow validates the confirmation, enters the selected protected environment, creates a saved destruction plan, publishes that plan in the workflow summary and applies the exact reviewed plan. Deleting the production resource group is possible only through this explicit manual workflow.

## Continuous delivery

Terraform creates the Azure platform. The application repositories then build, secure and deliver their artifacts through independent CI/CD and DevSecOps workflows:

1. Terraform provisions the Azure infrastructure and application deployment identities;
2. dedicated security workflows validate source code, dependencies, secrets and container artifacts;
3. the backend CI/CD pipeline builds and pushes the SHA-tagged backend image to ACR;
4. the backend image is deployed to Azure Linux Web App and `/actuator/health` is verified;
5. the frontend CI/CD pipeline builds and pushes the SHA-tagged frontend image to ACR;
6. the frontend image is deployed to Azure Linux Web App;
7. frontend availability, backend availability and CORS are verified;
8. runtime security checks such as DAST and frontend accessibility run against the successfully deployed applications.

A failed build, security gate, deployment or smoke test causes the corresponding GitHub Actions workflow to fail.

## Infrastructure security and governance

Infrastructure security is validated independently from the application security workflows.

| Control | Tool | Purpose |
| --- | --- | --- |
| IaC security | Trivy | Detect Terraform misconfigurations before infrastructure changes |
| Secret detection | Gitleaks | Detect credentials, tokens and other secrets in the repository and Git history |
| Dependency updates | Dependabot | Monitor Terraform providers and GitHub Actions dependencies |
| Authentication | GitHub OIDC | Authenticate to Azure without storing a long-lived Azure client secret |
| State | HCP Terraform | Remote state storage, versioning and locking |
| Governance | CODEOWNERS / protected environments | Control ownership and infrastructure deployment |

### IaC security

Trivy scans the Terraform configuration for infrastructure misconfigurations before changes are applied to Azure.

Infrastructure findings are reviewed in the context of the environment and Azure architecture. Security controls are corrected when applicable rather than being silently disabled to obtain a successful pipeline.

### Secret detection

Gitleaks scans the repository and Git history to prevent credentials, tokens and other secrets from being committed.

Azure authentication does not require a stored client secret because GitHub Actions uses OIDC federation.

The HCP Terraform API token is stored as a protected GitHub environment secret and is not committed to the repository.

### Controlled infrastructure changes

Infrastructure changes follow a deliberately controlled process:

```text
Pull Request
     |
     v
fmt + validate + security checks
     |
     v
Terraform plan
     |
     v
Review
     |
     v
Explicit manual apply
     |
     v
Azure
```

## Requirements coverage

| Requirement | Implementation |
|---|---|
| Pre-production matches production | Same immutable artifacts, services and process; only environment values change |
| Malfunctions reach developers | GitHub Actions logs and status, tests, scans, health checks and smoke tests |
| Containers are described on the platform | Backend Dockerfile, ACR image and Terraform-managed Web App configuration |
| Application updates reach users | Automatic deployment after validation and merge to `main` |

## Related repositories

- `bilan-azure-backend`: Spring Boot API, Docker image and backend pipeline;
- `bilan-azure-frontend`: Angular application, container image and Web App pipeline.

Local application validation is documented in [docs/local-validation.md](docs/local-validation.md), and Azure discovery in [docs/azure-environment.md](docs/azure-environment.md).

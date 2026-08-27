# Azure Quiz — Azure Infrastructure with Terraform

This repository describes and deploys the Azure Quiz infrastructure. The project automates the delivery of an Angular frontend and a containerized Spring Boot backend using managed Azure services.

## Status

The `nonprod` environment is deployed and operational:

- frontend: [Azure Static Web Apps](https://delightful-smoke-01664d103.7.azurestaticapps.net);
- backend API: [`/api/certifications`](https://app-azure-quiz-backend-nonprod.azurewebsites.net/api/certifications);
- backend health: [`/actuator/health`](https://app-azure-quiz-backend-nonprod.azurewebsites.net/actuator/health);
- remote state storage and locking in HCP Terraform;
- backend and frontend pipelines validated through deployment and smoke tests;
- latest Terraform check: no drift (`No changes`).

## Architecture

![Azure Quiz architecture](docs/architecture-managed-services.png)

Editable source: [architecture-managed-services.drawio](docs/architecture-managed-services.drawio).

```text
User
  |
  | HTTPS
  v
Azure Static Web Apps (Angular)
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

Azure Static Web Apps and Azure App Service were selected instead of AKS to reduce platform administration. There is no Kubernetes cluster, node pool, ingress controller or cluster upgrade to manage. The solution still demonstrates containerization, Infrastructure as Code, private networking, managed identities, secret management and continuous deployment.

## Deployed resources

| Component | Resource | Purpose |
|---|---|---|
| Frontend | `swa-hmezouar-quiz-np` | Public Angular hosting over HTTPS |
| Backend | `app-azure-quiz-backend-nonprod` | Spring Boot container hosting |
| Images | `acrhmezouarquiznonprod` | Private registry with admin access disabled |
| Database | `psql-hmezouar-quiz-np` | PostgreSQL 16 database `quizz` |
| Cache | `redis-hmezouar-quiz-np` | Azure Managed Redis with TLS |
| Files | `sthmezouarquiznp` | Blob container `application-files` |
| Secrets | `kv-hmezouar-quiz-np` | PostgreSQL and Redis secrets |
| Network | VNet `10.50.0.0/16` | Web App integration, private endpoints and DNS |
| Shared compute | `plan-npr-prf2026` | Trainer-provided Linux plan, referenced only |

Application resources are deployed in `hmezouarRG`, primarily in `francecentral`. Static Web Apps uses the nearby supported region `westeurope`. The shared App Service Plan belongs to `rg-shared-prf2026` and is not managed by this repository.

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
    ├── static-web-app/
    ├── storage/
    └── web-app/
```

Remote state is stored in the HCP Terraform organization `hmezouar-azure-quiz`, workspace `azure-quiz-nonprod`, using local execution mode. HCP Terraform stores, versions and locks the state while commands run locally.

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
5. An operator reviews the plan, manually runs **Actions > Terraform > Run workflow**, and enters exactly `apply-nonprod`.
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

The workflow validates the confirmation, enters the protected `nonprod` environment, creates a saved destruction plan, publishes that plan in the workflow summary and applies the exact reviewed plan. Deleting the `hmezouarRG` resource group itself is outside this workflow because the group is an existing project prerequisite rather than a Terraform-managed resource.

## Continuous delivery

Terraform creates the platform. The application repositories then deliver their artifacts:

1. the backend pipeline tests, builds and scans the Docker image;
2. it pushes the SHA-tagged image to ACR;
3. it deploys that image to Azure Web App and checks `/actuator/health`;
4. the frontend pipeline tests and builds Angular;
5. it publishes the reviewed static artifact to Azure Static Web Apps;
6. it verifies the frontend, backend and CORS policy.

A failed build, scan, deployment or smoke test makes the GitHub workflow fail and reports the malfunction to developers.

## Repository governance

- signed commits with the GitHub `Verified` badge;
- `CODEOWNERS` documenting ownership;
- Dependabot for Terraform providers and GitHub Actions;
- Trivy for IaC misconfiguration scanning;
- Gitleaks for secret detection across Git history;
- protected `main` branch with Pull Requests and required checks.

## Requirements coverage

| Requirement | Implementation |
|---|---|
| Pre-production matches production | Same immutable artifacts, services and process; only environment values change |
| Malfunctions reach developers | GitHub Actions logs and status, tests, scans, health checks and smoke tests |
| Containers are described on the platform | Backend Dockerfile, ACR image and Terraform-managed Web App configuration |
| Application updates reach users | Automatic deployment after validation and merge to `main` |

## Related repositories

- `bilan-azure-backend`: Spring Boot API, Docker image and backend pipeline;
- `bilan-azure-frontend`: Angular application and Static Web Apps pipeline.

Local application validation is documented in [docs/local-validation.md](docs/local-validation.md), and Azure discovery in [docs/azure-environment.md](docs/azure-environment.md).

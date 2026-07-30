# Azure environment discovery

This document records the Azure constraints identified before the Terraform
implementation.

## Subscription

The assigned training subscription was verified with Azure CLI. Its
subscription ID, tenant ID and signed-in identity are intentionally not
published in this repository. They are supplied through local environment
variables or GitHub Actions configuration.

## Assigned resource group

| Property | Value |
| --- | --- |
| Name | `hmezouarRG` |
| Region | `francecentral` |
| Existing resources at discovery time | None |
| Existing tags | None |

The resource group is provided to the learner and already exists. The Terraform
configuration must use it as an existing resource rather than attempting to
create or delete it.

## Confirmed permissions

The signed-in identity has the following effective assignments:

| Role | Scope |
| --- | --- |
| Reader | Subscription |
| Contributor | `hmezouarRG` |
| Owner | `hmezouarRG` |
| Role Based Access Control Administrator | Subscription |

These assignments permit resource creation and role assignments in the
dedicated resource group. They do not authorize modification of unrelated
resources.

## Shared App Service Plan

| Property | Value |
| --- | --- |
| Name | `plan-npr-prf2026` |
| Resource group | `rg-shared-prf2026` |
| Region | France Central |
| SKU | `S3` |
| Linux | Yes (`reserved = true`) |
| Tag | `scope = shared` |
| Tag | `managed_by = terraform` |

The App Service Plan is provided and managed by the trainer. This project must
reference it but must never create, update or destroy it.

The CI/CD workflow must discover the plan from its tags:

```bash
az appservice plan list \
  --query "[?tags.scope=='shared' && tags.managed_by=='terraform']"
```

The workflow must require exactly one match and fail safely if zero or multiple
matching plans are found.

The discovered resource ID will be passed to Terraform as an input. This avoids
hard-coding the shared plan name in the deployment workflow.

## Terraform remote state

The following backend configuration has been selected:

| Property | Value |
| --- | --- |
| Resource group | `hmezouarRG` |
| Storage Account name | `sthmezouartfstate` |
| Region | `francecentral` |
| Replication | `Standard_LRS` |
| Blob container | `tfstate` |
| State key | `nonprod/terraform.tfstate` |
| Authentication | Microsoft Entra ID |

The Storage Account name was confirmed as globally available. The resource has
not yet been created and must not be described as deployed. A separate
bootstrap configuration will create the Storage Account and private Blob
container before the first initialization of the main Terraform configuration.

The backend must enforce HTTPS, TLS 1.2 or later and disabled public Blob
access. Terraform state is sensitive and must never be committed to Git.

## Secrets and identities

- application secrets will be stored in Azure Key Vault;
- Key Vault will use Azure RBAC authorization;
- the backend Web App will use a system-assigned managed identity;
- the Web App identity will receive `Key Vault Secrets User` on the vault;
- GitHub Actions will authenticate with Azure through OpenID Connect;
- no Azure client secret will be stored in GitHub.

## Unrelated App Service Plan

The subscription also exposes the following plan:

| Property | Value |
| --- | --- |
| Name | `asp-dev-01` |
| Resource group | `asigurRG` |
| SKU | `B1` |
| Linux | Yes |
| Tags | None |

This plan does not carry the required shared-resource tags and does not belong
to this project. It must not be used or modified.

## Resource tagging requirements

Every applicable resource created by this project will use at least:

```text
owner       = hmezouar
environment = nonprod
project     = azure-quiz
component   = <resource role>
managed-by  = terraform
```

The exact Azure tag key format will be used consistently throughout Terraform
and CI/CD.

## Remaining checks

The following items must be confirmed before the first deployment:

- create and verify the selected Terraform remote-state Storage Account;
- grant the deployment identities the required Blob data role;
- permission to create Azure Container Registry;
- PostgreSQL Flexible Server SKU and regional availability;
- Azure Managed Redis SKU and regional availability;
- private endpoint and virtual network permissions;
- GitHub Actions OIDC identity and role assignments;
- registration state of the required Azure resource providers;
- globally unique names for the remaining Azure resources.

## Required resource providers

The registration state still needs to be recorded for:

- `Microsoft.Web`;
- `Microsoft.DBforPostgreSQL`;
- `Microsoft.Cache`;
- `Microsoft.Storage`;
- `Microsoft.KeyVault`;
- `Microsoft.ContainerRegistry`;
- `Microsoft.Insights`;
- `Microsoft.Network`.

Missing providers must not be registered without first confirming the expected
subscription governance process.

## Discovery date

The environment was inspected on 2026-07-30 before Terraform implementation.

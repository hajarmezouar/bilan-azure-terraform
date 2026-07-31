# Azure Deployment Plan

> **Status:** Validated

Generated: 2026-07-31

---

## 1. Project Overview

**Goal:** Replace the obsolete Azure Storage bootstrap with the initial,
conventional Terraform foundation for the Azure Quiz non-production
environment, using HCP Terraform for remote state and locking.

**Path:** Modernize existing infrastructure repository

This preparation step does not deploy Azure application resources.

---

## 2. Requirements

| Attribute | Value |
|-----------|-------|
| Classification | Non-production training project |
| Scale | Small |
| Budget | Cost-optimized, using the assigned shared App Service Plan |
| Subscription | `OCC_Toulouse_AdminCloud_190227_INTENSIF-PRF-2026` |
| Location | `francecentral` |
| Resource group | Existing `hmezouarRG` |
| State platform | HCP Terraform |
| HCP organization | `hmezouar-azure-quiz` |
| HCP workspace | `azure-quiz-nonprod` |
| HCP execution mode | Local |

The subscription ID remains outside the documentation and source code. It is
read from the active Azure CLI session when Terraform is run.

---

## 3. Components Detected

| Component | Type | Technology | Repository |
|-----------|------|------------|------------|
| Frontend | SPA | Angular | `bilan-azure-frontend` |
| Backend | REST API | Java Spring Boot, Docker | `bilan-azure-backend` |
| Infrastructure | Infrastructure as Code | Terraform, PowerShell, Make | `bilan-azure-terraform` |

The frontend and backend have already been launched together locally. This
plan changes only the infrastructure repository.

---

## 4. Recipe Selection

**Selected:** Terraform

**Rationale:**

- Terraform is explicitly required by the project;
- HCP Terraform is the selected remote state and locking platform;
- the existing workflow uses Terraform CLI, PowerShell and Make;
- a conventional environment root keeps non-production configuration separate
  from future reusable modules;
- no additional AZD layer is needed for this training repository.

---

## 5. Target Architecture

**Stack:** Managed Azure PaaS services

| Component | Azure service | Current decision |
|-----------|---------------|------------------|
| Angular frontend | Azure Static Web Apps | Public HTTPS entry point |
| Spring Boot container | Azure Linux Web App | Existing shared Linux App Service Plan |
| Container images | Azure Container Registry | Private registry |
| Relational data | PostgreSQL Flexible Server | Private endpoint |
| Cache | Azure Managed Redis | Private endpoint |
| Application files | Azure Storage | Private endpoint |
| Secrets | Azure Key Vault | Managed identity and private endpoint |
| Network isolation | VNet, integration subnet, private endpoint subnet, private DNS | Public access disabled for data services |
| Terraform state | HCP Terraform | Remote state and locking |

The shared App Service Plan is `plan-npr-prf2026` in
`rg-shared-prf2026`. Monitoring is intentionally deferred, following trainer
feedback.

### Scope of this preparation step

The first Terraform root will only:

- configure Terraform and the AzureRM provider;
- configure the HCP Terraform organization and workspace;
- read the existing project resource group;
- read the existing shared App Service Plan;
- expose safe outputs proving that the Azure context is correct.

Application and data resources will be added in later, reviewable commits.

---

## 6. Provisioning Limit Checklist

| Resource type | Number deployed in this step | Capacity result | Notes |
|---------------|------------------------------|-----------------|-------|
| Azure resources | 0 | Not applicable | This step contains data sources and Terraform/HCP configuration only |

**Status:** No Azure capacity or quota is consumed by this preparation step.
SKU availability and quotas must be checked before resource modules are added.

---

## 7. Planned File Changes

| File | Purpose | Action |
|------|---------|--------|
| `terraform/bootstrap/` | Obsolete Azure Storage state bootstrap | Removed |
| `scripts/bootstrap.ps1` | Obsolete bootstrap runner | Removed |
| `terraform/environments/nonprod/versions.tf` | Terraform, provider and HCP workspace configuration | Created |
| `terraform/environments/nonprod/providers.tf` | AzureRM provider configuration | Created |
| `terraform/environments/nonprod/variables.tf` | Typed environment inputs | Created |
| `terraform/environments/nonprod/locals.tf` | Naming and common tags | Created |
| `terraform/environments/nonprod/main.tf` | Existing resource group and shared plan data sources | Created |
| `terraform/environments/nonprod/outputs.tf` | Non-sensitive verification outputs | Created |
| `terraform/environments/nonprod/terraform.tfvars.example` | Documented, non-secret input example | Created |
| `scripts/terraform.ps1` | Format, init, validate, plan and output wrapper | Created |
| `Makefile` | Conventional Terraform targets | Replaced existing bootstrap targets |
| `.gitignore` | Ignore local state, plans and credentials | Preserved and refined |
| `README.md` and relevant ADRs | Align commands and state documentation with HCP Terraform | Updated |

The generated `terraform/bootstrap/.terraform/` directory and local
`terraform.tfstate` will also be removed. They are local build/state artifacts
and must never be committed.

---

## 8. Execution and Validation Checklist

### Planning

- [x] Inspect the infrastructure repository
- [x] Confirm subscription, region and resource group
- [x] Confirm HCP Terraform organization, workspace and Local execution
- [x] Identify obsolete Azure Storage bootstrap files
- [x] Select the Terraform repository structure
- [x] Obtain approval for this plan

### Execution after approval

- [x] Remove the obsolete bootstrap configuration and local artifacts
- [x] Create the non-production Terraform root
- [x] Add the HCP Terraform cloud configuration
- [x] Add existing Azure resource data sources
- [x] Replace the PowerShell and Make workflows
- [x] Align documentation
- [x] Set status to `Ready for Validation`

### Validation

- [x] Run `terraform fmt -check -recursive`
- [x] Run `terraform init`
- [x] Run `terraform validate`
- [x] Run a read-only `terraform plan`
- [x] Confirm HCP Terraform owns the remote state and lock
- [x] Confirm no Azure resource is proposed in the foundation plan
- [x] Review Git status and ensure no state, token or plan file is staged

No `terraform apply` or Azure deployment is included in this change.

---

## 9. Validation Proof

| Check | Command | Result | Timestamp |
|-------|---------|--------|-----------|
| Terraform installation | `terraform version` | Pass: Terraform 1.15.8 | 2026-07-31 10:09 +02:00 |
| Azure CLI installation | `az version` | Pass: Azure CLI 2.87.0 | 2026-07-31 10:09 +02:00 |
| HCP initialization | `terraform -chdir=terraform/environments/nonprod init -input=false` | Pass: HCP Terraform initialized, AzureRM 4.81.0 locked | 2026-07-31 10:09 +02:00 |
| Formatting | `terraform fmt -check -recursive` | Pass | 2026-07-31 10:09 +02:00 |
| Syntax validation | `terraform validate` | Pass | 2026-07-31 10:09 +02:00 |
| Azure plan | `terraform plan` with the active subscription | Pass: existing resource group and shared Linux S3 plan read successfully; output-only state changes and no Azure resource changes | 2026-07-31 10:09 +02:00 |
| HCP state | `terraform state list` | Expected empty workspace before first apply; HCP access already proven by init and plan | 2026-07-31 10:09 +02:00 |
| Static RBAC review | Search for `azurerm_role_assignment` | Not applicable: this foundation creates no identity or role assignment | 2026-07-31 10:09 +02:00 |
| Secret and Git hygiene | `git status`, `git check-ignore`, credential-pattern scan | Pass: plans, local state, provider cache and HCP credentials are ignored; no credential detected | 2026-07-31 10:09 +02:00 |

**Validated by:** Azure validation workflow

No deployment was run because this approved change is limited to the Terraform
foundation.

---

## 10. Next Step

Review and create a signed commit for the validated HCP Terraform foundation.
The next infrastructure iteration can then add the network module.

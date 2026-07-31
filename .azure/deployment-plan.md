# Azure Deployment Plan

> **Status:** Validated — network foundation iteration

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

Prepare the private network foundation as a separate Terraform iteration. The
planned scope is one VNet, an App Service integration subnet, a private
endpoint subnet, an NSG, private DNS zones and VNet links. No deployment is
authorized during preparation or validation.

---

## 11. Network Foundation Iteration

> **Status:** Validated

### Objective

Create a reusable Terraform network module for the non-production environment.
This iteration prepares private connectivity but does not create service
Private Endpoints; each service module will create its own endpoint and DNS
zone group later.

### Address plan

| Network | CIDR | Purpose |
|---------|------|---------|
| `vnet-azure-quiz-nonprod` | `10.50.0.0/16` | Project address space |
| `snet-appservice-integration` | `10.50.1.0/24` | App Service regional VNet integration |
| `snet-private-endpoints` | `10.50.2.0/24` | Private Endpoints for PaaS services |

The proposed address space does not overlap the three VNets currently visible
in the subscription (`10.0.0.0/16`, `10.0.0.0/24`, and `10.224.0.0/12`).
No peering is created in this iteration.

### Resources to create

| Terraform resource | Quantity | Security/configuration |
|--------------------|----------|------------------------|
| `azurerm_virtual_network` | 1 | Existing resource group and `francecentral`; common tags |
| `azurerm_subnet` | 2 | Separate integration and Private Endpoint subnets |
| `azurerm_network_security_group` | 1 | Integration subnet; controlled outbound and default-deny posture |
| `azurerm_subnet_network_security_group_association` | 1 | Associates the NSG only with the integration subnet |
| `azurerm_private_dns_zone` | 4 | PostgreSQL, Managed Redis, Blob Storage and Key Vault |
| `azurerm_private_dns_zone_virtual_network_link` | 4 | One non-autoregistering VNet link per zone |

Private DNS zone names:

- `privatelink.postgres.database.azure.com`;
- `privatelink.redis.azure.net`;
- `privatelink.blob.core.windows.net`;
- `privatelink.vaultcore.azure.net`.

The integration subnet is delegated to `Microsoft.Web/serverFarms`. Private
Endpoint network policies are disabled on the Private Endpoint subnet for
compatibility with the planned endpoints and enabled on the App Service
integration subnet. Default outbound access is disabled on both subnets. No
public IP, NAT Gateway, peering, route table or firewall is created.

### NSG rules

| Priority | Direction | Action | Destination | Ports | Purpose |
|----------|-----------|--------|-------------|-------|---------|
| 100 | Outbound | Allow | `VirtualNetwork` | Any | Reach private endpoints |
| 110 | Outbound | Allow | `AzureCloud` | 443 | Required Azure platform HTTPS dependencies |
| 4000 | Outbound | Deny | `Internet` | Any | Prevent unrestricted Internet egress |

The built-in NSG rules continue to deny unsolicited inbound traffic. More
restrictive egress through Azure Firewall is outside this cost-optimized
training scope.

### Policy and provisioning limits

- `Microsoft.Network` is registered;
- the only subscription policy assignment found is the default Defender for
  Cloud assignment; no network naming, location, tag or public-IP restriction
  was discovered;
- `Microsoft.Quota` is not registered, so quota CLI could not be used without
  changing subscription governance;
- fallback validation used current Azure CLI counts and Microsoft Learn's
  official non-adjustable networking limits.

| Resource | Add | Current | Total after | Limit | Result |
|----------|-----|---------|-------------|-------|--------|
| Virtual networks | 1 | 3 | 4 | 1,000 per region/subscription | Within limit |
| Subnets in the new VNet | 2 | 0 | 2 | 3,000 per VNet | Within limit |
| Network Security Groups | 1 | 3 | 4 | 5,000 per region/subscription | Within limit |
| Private DNS zones | 4 | 1 | 5 | 1,000 per subscription | Within limit |
| VNet links per new DNS zone | 1 | 0 | 1 | 1,000 per zone | Within limit |

No compute capacity, public IP or paid SKU quota is consumed by this module.

### Planned files

| File | Change |
|------|--------|
| `terraform/modules/network/main.tf` | Create network, NSG, DNS zones and links |
| `terraform/modules/network/variables.tf` | Define typed module inputs and CIDR validation |
| `terraform/modules/network/outputs.tf` | Export VNet, subnet and DNS zone IDs |
| `terraform/environments/nonprod/main.tf` | Instantiate the network module |
| `terraform/environments/nonprod/variables.tf` | Add overridable network CIDRs |
| `terraform/environments/nonprod/terraform.tfvars.example` | Document non-production network values |
| `terraform/environments/nonprod/outputs.tf` | Expose non-sensitive network outputs |
| `README.md` | Document the network module and commands |

### Validation after approval

1. `terraform fmt -recursive` and `terraform fmt -check -recursive`;
2. `terraform init -input=false`;
3. `terraform validate`;
4. read-only `terraform plan` using the active Azure subscription;
5. verify the exact resource count, CIDRs, delegation, DNS names and NSG rules;
6. verify there are no deletes, replacements, secrets or unignored state files.

No `terraform apply` is authorized in this iteration.

### Network validation proof

Validated on 2026-07-31 at 13:35 +02:00.

| Check | Result |
|-------|--------|
| Terraform installation | Pass: Terraform 1.15.8 |
| Azure CLI installation | Pass: Azure CLI 2.87.0 |
| HCP initialization | Pass: workspace initialized and network module discovered |
| Formatting | Pass: `terraform fmt -recursive` and format check |
| Syntax | Pass: `terraform validate` |
| Azure plan | Pass: `16 to add, 0 to change, 0 to destroy` |
| Plan action inspection | Pass: all 16 resource changes are create-only |
| Existing resources | Pass: `hmezouarRG` and the shared Linux S3 plan are read-only data sources |
| Subnet hardening | Pass: default outbound disabled on both subnets; Private Endpoint policies enabled only on the integration subnet |
| Network controls | Pass: App Service delegation, NSG association, controlled outbound rules and four non-autoregistering DNS links |
| Static RBAC review | Not applicable: this network-only module creates no identity or role assignment |
| Secret and state hygiene | Pass: no credential found; plans, provider cache and state are ignored |
| Git integrity | Pass: `git diff --check` reports no whitespace error |

The validated plan is saved locally as `.plans/nonprod-network.tfplan` and is
ignored by Git. It must not be applied from an unreviewed or later-modified
working tree.

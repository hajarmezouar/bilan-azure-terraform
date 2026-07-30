# ADR-0004: Store Terraform state in Azure Storage

## Status

Superseded by [ADR-0005](0005-hcp-terraform-state.md)

## Context

The infrastructure will be deployed locally and later through GitHub Actions.
Local Terraform state does not provide a shared source of truth, remote state
locking or suitable protection for collaborative deployment.

The main Terraform configuration cannot create the Storage Account that it
already needs during `terraform init`.

## Decision

A separate bootstrap configuration will create the remote-state resources in
the assigned resource group:

- Storage Account: `sthmezouartfstate`;
- resource group: `hmezouarRG`;
- region: `francecentral`;
- replication: `Standard_LRS`;
- Blob container: `tfstate`;
- non-production state key: `nonprod/terraform.tfstate`;
- authentication: Microsoft Entra ID;
- public Blob access: disabled;
- minimum TLS version: 1.2.

The selected Storage Account name was confirmed as globally available. It is
not considered deployed until the bootstrap operation succeeds.

## Consequences

- Terraform state is shared and supports state locking.
- Storage Account access keys do not need to be committed or placed in GitHub.
- Developers and GitHub Actions require an appropriate Blob data role.
- A separate bootstrap operation is required before the first main
  `terraform init`.
- State files and saved plan files must never be committed to Git.
- Terraform state must be treated as sensitive because it can contain generated
  credentials and previous values.

## Superseding decision

Following the architecture review, the project selected HCP Terraform instead
of creating a dedicated Azure Storage Account. The Azure bootstrap described by
this ADR was planned but not applied.

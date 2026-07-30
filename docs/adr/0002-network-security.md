# ADR-0002: Network security model

## Status

Accepted

## Context

The specification defines the intended communication path:

```text
Internet -> frontend -> backend -> data services
```

The frontend should be the only user-facing component. PostgreSQL, Redis,
Storage and Key Vault must not be directly accessible by application users.

Azure Static Web Apps can require a publicly reachable backend origin. This
makes strict network-level isolation of the App Service difficult with the
selected hosting target.

## Decision

Implement the following access model:

- Azure Static Web Apps is the public entry point;
- all public communication uses HTTPS;
- Angular calls the Spring Boot Web App through its HTTPS API;
- CORS allows only the exact Static Web Apps origin;
- the backend requires authentication or equivalent API access control;
- the frontend never connects directly to data services;
- create an Azure Virtual Network with a delegated App Service integration
  subnet and a dedicated private endpoint subnet;
- integrate the backend Web App with the Virtual Network for private outbound
  traffic;
- create private endpoints for PostgreSQL, Azure Managed Redis, application
  Blob Storage and Key Vault;
- link the matching private DNS zones to the Virtual Network;
- disable public network access on PostgreSQL, Redis, Storage and Key Vault
  when supported by the selected regional SKUs;
- the Web App uses managed identity for supported Azure service access;
- network rules and access restrictions are defined with Terraform.

## Alternatives considered

### Fully private Web App

A private endpoint and disabled public access would provide stronger network
isolation, but Static Web Apps might no longer be able to reach the backend.

### CORS only

CORS alone was rejected as a security boundary. It restricts compliant browser
clients but does not prevent direct HTTP requests to the backend.

### Shared API key in Angular

A key included in compiled Angular code cannot be considered secret because
users can inspect browser-delivered files. If the supplied application requires
this mechanism for the exercise, its limitation must remain explicitly
documented.

## Consequences

- the Web App may retain a public HTTPS endpoint;
- application-level access control is required;
- backend-to-data traffic uses Virtual Network integration, private endpoints
  and private DNS;
- data services remain isolated from application users and the public Internet;
- the limitation and mitigations must be verified with positive and negative
  connectivity tests.

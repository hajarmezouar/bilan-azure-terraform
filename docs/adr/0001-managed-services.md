# ADR-0001: Use Azure managed services

## Status

Accepted

## Context

The Azure Quiz application consists of an Angular frontend and a Spring Boot
backend. The target environment must also provide PostgreSQL, Redis, object
storage, secret management, observability and automated deployment.

The project specification permits two hosting targets:

- Azure Kubernetes Service;
- Azure managed services.

The trainer provides a shared App Service Plan. The implementation period is
limited, and operating Kubernetes is not a project requirement by itself.

## Decision

Use Azure managed services:

- Azure Static Web Apps for the Angular frontend;
- Azure Linux Web App for the Spring Boot container;
- the trainer-provided shared App Service Plan;
- Azure Container Registry for backend images;
- PostgreSQL Flexible Server;
- Azure Managed Redis;
- Azure Storage;
- Azure Key Vault.

Application Insights, Log Analytics and Azure Monitor are deferred to a later
iteration and are not part of the initial deployment.

## Alternatives considered

### Azure Kubernetes Service

AKS would provide more control over container orchestration, internal
networking, rolling updates and workload isolation.

It was rejected because it introduces additional work for Kubernetes manifests,
ingress, network policies, cluster permissions and operational troubleshooting.
The managed-services option better matches the available implementation time.

## Consequences

### Positive

- reduced operational complexity;
- faster implementation;
- built-in scaling, TLS and platform maintenance;
- native integration with GitHub Actions;
- the Spring Boot backend remains containerized.

### Negative

- less control over the hosting platform;
- the frontend is not deployed as a running container;
- strict private isolation of the Web App may not be compatible with Static Web
  Apps integration.

The backend-access limitation is addressed in ADR-0002.

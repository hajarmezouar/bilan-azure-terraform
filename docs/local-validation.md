# Local application validation

## Status

Successful

## Date

2026-07-30

## Objective

Validate the supplied application locally before implementing its Azure
infrastructure.

## Components

- Angular frontend;
- Spring Boot backend;
- PostgreSQL through Docker Compose;
- Redis through Docker Compose;
- Azurite through Docker Compose.

## Commands

Backend:

```bash
cd /mnt/c/Users/Utilisateur/Documents/GitHub/bilan-azure-backend
./mvnw spring-boot:run
```

Frontend, in a separate terminal:

```bash
cd /mnt/c/Users/Utilisateur/Documents/GitHub/bilan-azure-frontend
npm start
```

## Result

- the Spring Boot application started on port `8080`;
- the backend health endpoint responded;
- the Angular application started on port `4200`;
- the frontend communicated successfully with the backend;
- the application was usable through the browser.

No application source change was required for this validation.

## Architecture implications

The local validation confirms the following production dependencies:

| Local component | Target Azure service |
| --- | --- |
| Angular development server | Azure Static Web Apps |
| Spring Boot process | Azure Linux Web App |
| PostgreSQL container | PostgreSQL Flexible Server |
| Redis container | Azure Managed Redis |
| Azurite | Azure Storage Account |

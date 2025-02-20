# AKV PoC

This project is a Proof of Concept (PoC) for collecting Azure Key Vault (AKV) access events and storing the data in CosmosDB. AKV diagnostics settings are configured to store audit events in Log Analytics. kvReader Function App reads the Key Vault secrets. kvEventListener Function App reads data from Log Analytics, processes them, and stores them in CosmosDB containers. Bicep is used for infrastructure as code.

## Table of Contents

- [Infrastructure](#infrastructure)
  - [Main Bicep File](#main-bicep-file)
  - [Modules](#modules)
- [Source Code](#source-code)
  - [kvListener](#kvlistener)
  - [kvReader](#kvreader)
  - [my-azure-function-app](#my-azure-function-app)
- [Deployment](#deployment)
  - [Prerequisites](#prerequisites)
  - [Infrastructure](#infrastructure-deployment)
  - [Application](#application-deployment)
- [Usage](#usage)
- [License](#license)
- [Contributing](#contributing)

## Infrastructure

The infrastructure is defined using Bicep files located in the `infra` directory.

### Main Bicep File

The main Bicep file is [main.bicep](infra/main.bicep). It orchestrates the deployment of various Azure resources including:

- User Managed Identity
- Log Analytics Workspace
- Cosmos DB
- Function App
- Key Vault
- Storage Account

### Modules

The `modules` directory contains individual Bicep files for each resource:

- [cosmosDb.bicep](infra/modules/cosmosDb.bicep)
- [functionApp.bicep](infra/modules/functionApp.bicep)
- [identity.bicep](infra/modules/identity.bicep)
- [keyVault.bicep](infra/modules/keyVault.bicep)
- [logAnalytics.bicep](infra/modules/logAnalytics.bicep)
- [policies.bicep](infra/modules/policies.bicep)
- [sqlServer.bicep](infra/modules/sqlServer.bicep)
- [storageAccount.bicep](infra/modules/storageAccount.bicep)

## Source Code

The `src` directory contains the source code for the Azure Function Apps and other related components.

### kvListener

The `kvListener` directory contains the code for the Key Vault listener. There are two versions of kvEventListener written in C# and Powershell.

### kvReader

The `kvReader` directory contains the code for reading from the Key Vault.

## Deployment

### Infrastructure
To deploy the infrastructure, run the following command:

1. Create a resource group:

```sh
az group create --name <your-resource-group> --location <your-location>
```

2. Deploy the infrastructure:
```sh
az deployment group create --resource-group <your-resource-group> --template-file infra/main.bicep --parameters @infra/main.parameters.json
```
### Application

1. Create a document in CosmosDB container Config:
```
{
    "id": "1",
    "eventDate": "2025-01-01"
}
```
2. Deploy kvReader Function App
3. Run few requests to Function Apps endpoint adding query string parameter name specifying the name of one of the secrets in Key Vault, e.g. https://<your-func-app-name>.azurewebsites.net/api/KeyVaultReader?name=testkey1.
4. Wait for the SecretGet events to appear in Log Analytics workspace.
5. Deploy kvEventListener Function App
6. Wait for the kvEventListener timer trigger to run the function and check the results in CosmosDB containers.
7. Repeat steps 3, 4 to generate more events and validate if data is being updated in CosmosDB.
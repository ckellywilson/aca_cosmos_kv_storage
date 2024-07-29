# Azure Container Apps Deployment with CosmosDB and Azure Storage

This repository is an example of using Azure Container Apps to deploy a containerized application that uses CosmosDB and Azure Storage. The application is a simple Angular application that allows users to upload files to Azure Storage and view the uploaded files.

## Prerequisites
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [Node.js](https://nodejs.org/en/download/)

## Setup
1. Clone this repository
1. Ensure you have adminstrator access to an Azure subscription
1. Open a terminal and navigate to the root of the repository
1. Open the following script based on your environment:
	- [Windows](scripts/setup.ps1)
	- [Linux/Mac](scripts/setup.sh)

## Deploy the Application
1. In the script, update the variable `prefix` with a unique prefix for your resources`. __<b>NOTE: The prefix must be between 0-6 lowercase characters with no spaces or special characters.</b>__
1. 1. Run the script
1. The script will create the following Azure resources:
	- Resource Group
	- Azure Container Apps
	- CosmosDB
	- Azure Storage
	- Azure Container Registry
	- Azure Key Vault

## Access the Application
1. Once the script has completed, it will output the URL to access the application
1. Open the URL in a browser


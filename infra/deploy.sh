#!/bin/bash

# Login to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Variables
# Get the Azure AD signed-in user ID
echo "Getting the Azure AD signed-id user ID..."
adminUserId=$(az ad signed-in-user show --query "id" --output tsv)
echo "adminUserId: $adminUserId"

prefix="poc-ecolab"
deploymentName="${prefix}-deployment"
location="centralus"

# Deploy AKS cluster using Bicep template
az deployment sub create --name $deploymentName \
    --location $location \
    --parameters ./bicep/main.bicepparam
    --parameters prefix="$prefix" \
    --template-file ./bicep/main.bicep

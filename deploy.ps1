
# 

# Login to Azure
Write-Host "Logging in to Azure..."
# az login --use-device-code

# Variables
# Get the Azure AD signed-in user ID
Write-Host "Getting the Azure AD signed-id user ID..."
$adminUserId=$(az ad signed-in-user show --query "id" --output tsv)
Write-Host "adminUserId: $adminUserId"

# Set the prefix for all resources
Write-Host "Setting the prefix for all resources..."
$prefix="ecolab"
Write-Host "prefix: $prefix"

# Set the deployment name
Write-Host "Setting the deployment name..."
$deploymentName="${prefix}-deployment"
Write-Host "deploymentName: $deploymentName"

# Set the app registration name variable
Write-Host "Setting the app registration name variable..."
$appRegistrationName="contextmapimage"
Write-Host "appRegistrationName: $appRegistrationName"

# Set the location
Write-Host "Setting the location..."
$location="centralus"
Write-Host "location: $location"

# Deploy AKS cluster using Bicep template
Write-Host "Deploying AKS cluster using Bicep template..."
az deployment sub create --name $deploymentName `
    --location $location `
    --parameters ./infra/bicep/main.bicepparam `
    --parameters prefix="$prefix" `
    --parameters adminUserId="$adminUserId" `
    --template-file ./infra/bicep/main.bicep
Write-Host "Deployment completed successfully."

# show the outputs
Write-Host "Showing the outputs..."
az deployment sub show --name $deploymentName --query "properties.outputs"
Write-Host "Deployment completed successfully."

# Get key vault name
Write-Host "Getting key vault name..."
$keyVaultName=$(az deployment sub show --name $deploymentName --query "properties.outputs.keyVaultName.value" --output tsv)
Write-Host "keyVaultName: $keyVaultName"

# create app registration $appRegistrationName for rbac
Write-Host "Creating app registration for RBAC for "$appRegistrationName
$appRegistrationSecret=$(az ad sp create-for-rbac --name $appRegistrationName --query "password" --output tsv)
Write-Host "App registration created successfully."
Write-Host "appRegistrationSecret: "$appRegistrationSecret

# add app registration secret to key vault
Write-Host "Adding app registration secret to key vault..."
az keyvault secret set --vault-name $keyVaultName --name $appRegistrationName"secret" --value $appRegistrationSecret

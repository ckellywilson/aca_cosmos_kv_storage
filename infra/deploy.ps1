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

# Set the location
Write-Host "Setting the location..."
$location="centralus"
Write-Host "location: $location"

# Deploy AKS cluster using Bicep template
Write-Host "Deploying AKS cluster using Bicep template..."
az deployment sub create --name $deploymentName `
    --location $location `
    --parameters ./bicep/main.bicepparam `
    --parameters prefix="$prefix" `
    --parameters adminUserId="$adminUserId" `
    --template-file ./bicep/main.bicep
Write-Host "Deployment completed successfully."

# show the outputs
Write-Host "Showing the outputs..."
az deployment sub show --name $deploymentName --query "properties.outputs"
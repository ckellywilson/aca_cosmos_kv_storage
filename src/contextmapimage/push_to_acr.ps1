# Set the Docker image name
Write-Host "Set the Docker image name"
$imageName='contextmapimage'
Write-Host "Docker image name: $imageName"

# Login to Azure
Write-Host "Login to Azure"
# az login --use-device-code

# Build project
Write-Host "Build project"
dotnet build

# Set the Azure Container Registry details
Write-Host "Set the Azure Container Registry name"
$acr_name=$(az resource list --query "[?tags.environment=='ecolab' && type=='Microsoft.ContainerRegistry/registries'].name" --output tsv)
Write-Host "Azure Container Registry name: $acr_name"

# Login to Azure Container Registry
Write-Host "Login to Azure Container Registry"
az acr login --name $acr_name

# Build and tag the Docker image
Write-Host "Build and tag the Docker image"
docker build -t $imageName . --no-cache
$image_id=$(docker images -q $imageName)
Write-Host "Docker image ID: $imageName"

# Tag the Docker image with the Azure Container Registry URL
Write-Host "Tag the Docker image with the Azure Container Registry URL"
docker tag $imageName':latest' $acr_name'.azurecr.io/'$imageName':latest'
Write-Host "Docker image tagged with Azure Container Registry URL"

# Push the Docker image to Azure Container Registry
Write-Host "Push the Docker image to Azure Container Registry"
docker push $acr_name'.azurecr.io/'$imageName':latest'
Write-Host "Docker image pushed to Azure Container Registry"
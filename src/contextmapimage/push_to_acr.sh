#!/bin/bash

# Set the Docker image name
echo "Set the Docker image name"
imageName='contextmapimage'
echo "Docker image name: $imageName"

# Login to Azure
echo "Login to Azure"
az login --use-device-code

# Build project
echo "Build project"
dotnet build

# Set the Azure Container Registry details
echo "Set the Azure Container Registry name"
acr_name=$(az resource list --query "[?tags.environment=='ecolab-aca' && type=='Microsoft.ContainerRegistry/registries'].name" --output tsv)
echo "Azure Container Registry name: $acr_name"

# Login to Azure Container Registry
echo "Login to Azure Container Registry"
az acr login --name $acr_name

# Build and tag the Docker image
echo "Build and tag the Docker image"
docker build -t $imageName . --no-cache
image_id=$(docker images -q $imageName)
echo "Docker image ID: $image_name"

# Tag the Docker image with the Azure Container Registry URL
echo "Tag the Docker image with the Azure Container Registry URL"
docker tag $imageName:latest $acr_name.azurecr.io/$imageName:latest
echo "Docker image tagged with Azure Container Registry URL"

# Push the Docker image to Azure Container Registry
echo "Push the Docker image to Azure Container Registry"
docker push $acr_name.azurecr.io/$imageName:latest
echo "Docker image pushed to Azure Container Registry"
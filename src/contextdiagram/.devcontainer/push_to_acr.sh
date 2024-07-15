#!/bin/bash

imageName='contextdiagram'
echo 'Image Name: ' $imageName

# Login to Azure
az login --use-device-code

# Set the Azure Container Registry details
acr_name=$(az resource list --query "[?tags.environment=='ecolab-aca' && type=='Microsoft.ContainerRegistry/registries'].name" --output tsv)

# Login to Azure Container Registry
az acr login --name $acr_name

# Build and tag the Docker image
docker build -t $imageName .

# Tag the Docker image with the Azure Container Registry URL
docker tag $imageName $acr_name.azurecr.io/$imageName:latest

# Push the Docker image to Azure Container Registry
docker push $acr_name.azurecr.io/$imageName:latest
#!/bin/bash

export PREFIX="bicepk8s"
export SUFFIX="rg"
export RG_NAME=$PREFIX-$SUFFIX
export RG_LOCATION="eastus"
export BICEP_FILE="main.bicep"

# Create the Resource Group to deploy the Webinar Environment
az group create --name $RG_NAME --location $RG_LOCATION

# Deploy AKS cluster using bicep template
az deployment group create \
  --name bicepk8sdeploy \
  --resource-group $RG_NAME \
  --template-file $BICEP_FILE
#!/bin/bash

export PREFIX="k8supdemo"
export SUFFIX="rg"
export RG_NAME=$PREFIX-$SUFFIX
export RG_LOCATION="eastus"
# export BICEP_FILE="000-main.bicep"
# export WEBINAR_PARAMETERS="@parameters.json"
export SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" \

az group create --name $RG_NAME --location $RG_LOCATION




#!/bin/bash

export PREFIX="clik8s"
export SUFFIX="rg"
export RG_NAME=$PREFIX-$SUFFIX
export LOCATION="eastus"
export CLUSTER_NAME="clik8sup"
export SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" \

# create a new resource group
az group create --name $RG_NAME --location $LOCATION

# create aks cluster with 3 nodes
az aks create -g $RG_NAME -n $CLUSTER_NAME -c 3 --ssh-key-value $SSH_KEY -k 1.19.7





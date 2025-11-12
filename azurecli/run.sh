#!/bin/bash

export PREFIX="clik8s"
export SUFFIX="rg"
export RG_NAME=$PREFIX-$SUFFIX
export LOCATION="eastus"
export CLUSTER_NAME="clik8sup"

# create a new resource group
az group create --name $RG_NAME --location $LOCATION

# create aks cluster with 3 nodes
az aks create \
-g $RG_NAME \
-n $CLUSTER_NAME \
--enable-managed-identity \
-c 3 \
--ssh-key-value /home/$USER/.ssh/id_rsa.pub \
-k 1.34.1 \
--enable-cluster-autoscaler \
--min-count 3 \
--max-count 5 \
--load-balancer-sku standard




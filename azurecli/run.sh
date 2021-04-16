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
-g $RG_NAME \ # resource group name
-n $CLUSTER_NAME \ # cluster name
--enable-managed-identity \ # enable managed identity vs. service principal
-c 3 \ # 3 nodes
--ssh-key-value /home/$USER/.ssh/id_rsa.pub \ # ssh keys to log into nodes
-k 1.19.7 \ # kubernetes version
--enable-cluster-autoscaler \ # enable cluster autoscaler
--min-count 3 \ # minimum of 3 nodes (for the autoscaler)
--max-count 5 \ # maximum of 5 nodes (for the autoscaler)
--load-balancer-sku standard # create a standard azure load balancer





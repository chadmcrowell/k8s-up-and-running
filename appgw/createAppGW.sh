#!/bin/bash

# create new pub ip
az network public-ip create -n RobotAppIP -g bicepk8s-rg --allocation-method Static --sku Standard

# create app gw
PUBIP=$(az network public-ip list -g bicepk8s-rg --query [1].name -o tsv)
az network application-gateway create -n robotAppGW -l eastus -g bicepk8s-rg --sku Standard_v2 --public-ip-address $PUBIP

# enable acig add-on
appgwId=$(az network application-gateway show -n robotAppGW -g bicepk8s-rg -o tsv --query "id")
az aks enable-addons -n bicep-k8sup -g bicepk8s-rg -a ingress-appgw --appgw-id $appgwId

# peer the aks vnet to the appgw vnet
aksVnetName=$(az network vnet list -g bicepk8s-rg -o tsv --query "[0].name")

aksVnetId=$(az network vnet show --name $aksVnetName -g bicepk8s-rg -o tsv --query "id")
az network vnet peering create -n AppGWtoAKSVnetPeering -g bicepk8s-rg --vnet-name robotAppGWVnet --remote-vnet $aksVnetId --allow-vnet-access

appGWVnetId=$(az network vnet show -n robotAppGWVnet -g bicepk8s-rg -o tsv --query "id")
az network vnet peering create -n AKStoAppGWVnetPeering -g bicepk8s-rg --vnet-name $aksVnetName --remote-vnet $appGWVnetId --allow-vnet-access
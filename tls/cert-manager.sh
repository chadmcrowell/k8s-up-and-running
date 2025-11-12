# get fqdn of pubic ip
az network public-ip list --resource-group bicepk8s-rg --query "[?name=='RobotAppIP'].[dnsSettings.fqdn]" -o tsv

# give fqdn to public ip
az network public-ip update -g bicepk8s-rg -n RobotAppIP --dns-name robotshop --allocation-method Static

# generate key
openssl genrsa -out ca.key 2048

# create certificate
openssl req -x509 -new -nodes -key ca.key -sha256 -subj "/CN=robotshop.eastus.cloudapp.azure.com" -days 1024 -out ca.crt -extensions v3_ca -config /etc/ssl/openssl.cnf

# create secret
kubectl create secret tls rbot-tls --key=ca.key --cert=ca.crt

# add repo to helm
helm repo add jetstack https://charts.jetstack.io

# update helm repos
helm repo update

# create ns
kubectl create ns cert-manager

# install cert manager
helm upgrade --install \
cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.15.1 \
--set crds.enabled=true

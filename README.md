## k8s-up-and-running

Infrastructure-as-code samples for provisioning an Azure Kubernetes Service (AKS) cluster running Kubernetes **1.34.1**. Each approach creates the same baseline cluster (3 nodes, System Assigned managed identity, Azure CNI networking) so you can choose the tooling that best matches your workflow.

### Repo layout

- `terraform/` – Terraform configuration that stands up the resource group and AKS cluster.
- `bicep/` – Bicep template targeting the latest AKS and virtual network API versions.
- `azurecli/` – Shell script that provisions AKS with the Azure CLI.
- `powershell/` – ARM template + parameters for PowerShell/`New-AzResourceGroupDeployment`.
- `tls/` and `appgw/` – Supporting manifests and scripts for ingress, cert-manager, and Application Gateway integration.

### Prerequisites

- Azure subscription with permission to create resource groups, VNets, and AKS clusters.
- Azure CLI 2.49.0+ (or Az PowerShell module 10.0+ if using the PowerShell path).
- Terraform 1.5+ for the Terraform workflow.
- `kubectl`, `helm`, and (optionally) the Bicep CLI for validation and post-deployment configuration.

### How to deploy

1. **Terraform**  
   ```bash
   cd terraform
   terraform init
   terraform apply -var "prefix=<yourprefix>" -var "location=eastus"
   ```
2. **Bicep**  
   ```bash
   cd bicep
   az deployment group create \
     --resource-group <rg> \
     --template-file main.bicep \
     --parameters dnsPrefix=<prefix> clusterName=<name>
   ```
3. **Azure CLI**  
   ```bash
   cd azurecli
   ./run.sh
   ```
4. **PowerShell**  
   ```powershell
   cd powershell
   New-AzResourceGroupDeployment `
     -ResourceGroupName <rg> `
     -TemplateFile main.json `
     -TemplateParameterFile parameters.json
   ```

Each workflow provisions the same AKS cluster, so you only need to run one of them. After deployment, use `kubectl get nodes` or `az aks show -g <rg> -n <cluster>` to confirm the control plane reports `kubernetesVersion` `1.34.1`.

### Next steps

- Apply ingress manifests under `appgw/` or `tls/` to expose workloads.
- Use `tls/cert-manager.sh` to bootstrap cert-manager v1.15 and issue certificates.
- Clean up when finished: `terraform destroy`, `az group delete`, or `Remove-AzResourceGroup` depending on the path you took.

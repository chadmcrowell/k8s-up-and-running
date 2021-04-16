variable "prefix" {
	type = string
	description = "Value to prefix resource names with."
	default = "tfk8sup"
}

variable "suffix" {
  type = string
	description = "Value used for resource names suffix."
	default = "rg"
}

variable "vnetPrefix" {
  type = string
  description = "Azure VNET CIDR Prefix/range"
  default =  "10.0.0.0/16"
}

variable "kubernetes_version" {
  type = string
  description = "K8s Version"
  default = "1.19.7"
}

variable "adminUsername" {
  type = string
  description = "Admin User name for k8s work nodes/agents"
  default = "azureuser"
}

variable "adminPublicKey" {
  type = string
  description = "SSH Public Key for remote login to nodes"
  default = "~/.ssh/id_rsa.pub"
}

variable "location" {
	type = string
	description = "Default Azure Region"
	default = "eastus"
}

variable "admin_group_object_ids" {
  type = list(string)
  description = "AAD GroupID used as K8s Admin Group"
  default = []
}

variable "subnet_id" {
  type = string
}

variable "resource_group" {
}

variable aks_settings {
	type = object({
		kubernetes_version		= string
		identity 				= string
		outbound_type			= string
		network_plugin			= string
		network_policy			= string
		load_balancer_sku		= string
		service_cidr			= string
		dns_service_ip 			= string
		docker_bridge_cidr 		= string
		sku_tier				= string
		role_based_access_control_enabled = bool
		azure_active_directory_managed = bool
		admin_group_object_ids  = list(string)
		ssh_key					= string
	})
	default = {
		kubernetes_version		= null
		identity 				= "SystemAssigned"
		outbound_type			= "loadBalancer"
		network_plugin			= "azure"
		network_policy			= "calico"
		load_balancer_sku		= "standard"
		service_cidr			= "172.16.0.0/22"
		dns_service_ip 			= "172.16.0.10"
		docker_bridge_cidr 		= "172.16.4.1/22"
		sku_tier				= "Paid"
		role_based_access_control_enabled = true
		azure_active_directory_managed = true
		admin_group_object_ids  = [null]
		ssh_key					= "~/.ssh/id_rsa.pub"
		# admin_username			= "azureuser"
		# ssh_key					= null
	}
}

variable default_node_pool {
	type = object({
		name = string
		enable_auto_scaling = bool
		node_count = number
		min_count = number
		max_count = number
		vm_size = string
		type    = string
		os_disk_size_gb = number
		only_critical_addons_enabled = bool
	})
	
	default = {
		name = "defaultnp"
		enable_auto_scaling = true
		node_count = 3
		min_count = 3
		max_count = 5
		vm_size = "Standard_D4s_v3"
		type    = "VirtualMachineScaleSets"
		os_disk_size_gb = 30
		only_critical_addons_enabled = true
	}
}

# variable user_node_pools {
# 	type = map(object({
# 		vm_size = string
# 		node_count = number
# 		node_labels = map(string)
# 		node_taints = list(string)
# 		mode = string
# 	}))
	
# 	default = {
# 		"usernp1" = {
# 			vm_size = "Standard_D4s_v3"
# 			node_count = 3
# 			node_labels = null
# 			node_taints = []
# 			mode = "User"
# 		}
# 	}
# }
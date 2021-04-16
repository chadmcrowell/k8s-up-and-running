terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = "~> 2.51.0"
		}
	}
}

provider azurerm {
	features {}
}

resource random_string suffix {
  length = 4
  special = false 
  upper = false
  lower = true
  number = false
}

locals {
	prefix = var.prefix
	suffix = var.suffix
}

resource "azurerm_resource_group" "default" {
  name = "${local.prefix}-${local.suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name = "${azurerm_resource_group.default.name}-vnet"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.4.0/22"]
  # enforce_private_link_service_network_policies = false  
  enforce_private_link_endpoint_network_policies = false
}

resource azurerm_kubernetes_cluster dev {
  name                = "${local.prefix}-${var.suffix}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  
  dns_prefix          = "${local.prefix}-aks-cluster"
  
  kubernetes_version  = var.aks_settings.kubernetes_version
  private_cluster_enabled = false

  default_node_pool {
    name                = var.default_node_pool.name
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    type                = var.default_node_pool.type
    vnet_subnet_id      = var.subnet_id
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
  }

  identity {
    type = var.aks_settings.identity
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key					{
      key_data = file(var.aks_settings.ssh_key)
    }
  }

  network_profile {
    network_plugin     = var.aks_settings.network_plugin
    network_policy     = var.aks_settings.network_policy
    load_balancer_sku  = var.aks_settings.load_balancer_sku
    service_cidr       = var.aks_settings.service_cidr
    dns_service_ip     = var.aks_settings.dns_service_ip
    docker_bridge_cidr = var.aks_settings.docker_bridge_cidr
    outbound_type      = var.aks_settings.outbound_type
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
  }
  
  sku_tier = var.aks_settings.sku_tier

  role_based_access_control {
    enabled = var.aks_settings.role_based_access_control_enabled

    azure_active_directory {
      managed = var.aks_settings.azure_active_directory_managed
      admin_group_object_ids = var.aks_settings.admin_group_object_ids
    }    
  }

}

# resource azurerm_kubernetes_cluster_node_pool user {
#   for_each = var.user_node_pools

#   name                  = each.key
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.dev.id
#   vm_size               = each.value.vm_size
#   node_count            = each.value.node_count
#   mode                  = each.value.mode
#   node_labels           = each.value.node_labels
#   vnet_subnet_id        = var.subnet_id
#   node_taints           = each.value.node_taints
# }
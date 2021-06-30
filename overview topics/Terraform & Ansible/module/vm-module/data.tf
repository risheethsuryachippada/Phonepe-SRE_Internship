 data "azurerm_resource_group" "stg-ins-rg" {
   name = var.resource_group_name
 }

# data "azurerm_virtual_network" "stg-ins-vnet" {
#   name                = "vnet_stg_ins"
#   resource_group_name = "rg_stg_ins"
# }

data "azurerm_subnet" "stg-ins-subnet" {
  name                 = var.az_subnet_name
  virtual_network_name = var.az_vnet_name
  resource_group_name  = var.az_subnet_rg_name
}


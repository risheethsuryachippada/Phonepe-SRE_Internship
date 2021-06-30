resource "azurerm_network_security_group" "vm-nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "vm" {
  name                        = var.nsg_rule_name
  description                 = var.description
  priority                    = var.priority
  direction                   = var.direction
  access                      = var.access
  protocol                    = var.protocol
  source_port_range           = var.source_port_range
  source_address_prefix       = var.source_address_prefix
  destination_address_prefix  = var.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.vm-nsg.name

  destination_port_ranges = var.destination_port_range
}

resource "azurerm_network_security_rule" "vm_deny_outbound_internet" {
  name                        = "DenyInternetOutBound"
  description                 = "DenyInternetOutBound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.vm-nsg.name

  destination_port_range = "*"
}

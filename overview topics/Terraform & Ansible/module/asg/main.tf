

resource "azurerm_application_security_group" "asg" {
  name                = var.asg_name
  location            = var.location
  resource_group_name = var.resource_group_name

}
output "network_security_group_id" {
  description = "id of the security group provisioned"
  value       = "${azurerm_network_security_group.vm-nsg.id}"
}

output "network_security_group_name" {
  description = "name of the security group provisioned"
  value       = "${azurerm_network_security_group.vm-nsg.name}"
}

output "vm_id" {
  description = "id of the security group provisioned"
  value       = "${azurerm_virtual_machine.vm-linux.*.id}"
}

output "vm_name" {
  description = "id of the security group provisioned"
  value       = "${azurerm_virtual_machine.vm-linux.*.name}"
}

// output  "principal_id" {
//   value = "${azurerm_virtual_machine.vm-linux.*.identity.0.principal_id}"
// }

# output "network_security_group_id" {
#   description = "id of the security group provisioned"
#   value       = "${azurerm_network_security_group.vm-nsg.id}"
# }

# output "network_security_group_name" {
#   description = "name of the security group provisioned"
#   value       = "${azurerm_network_security_group.vm-nsg.name}"
# }

output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = "${azurerm_network_interface.staging_base_NIC.*.id}"
}

output "network_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.staging_base_NIC.*.private_ip_address}"

}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${element(azurerm_network_interface.staging_base_NIC.*.private_ip_address, 0)}"

}

# output "public_ip_id" {
#   description = "id of the public ip address provisoned."
#   value       = "${azurerm_public_ip.staging_dynamic_public_base_ip.*.id}"
# }

# output "public_ip_address" {
#   description = "The actual ip address allocated for the resource."
#   value       = "${azurerm_public_ip.staging_dynamic_public_base_ip.*.ip_address}"
#   # value = "${element(azurerm_public_ip.staging_dynamic_public_base_ip.*.ip_address, 0)}"
# }

// output "public_ip_dns_name" {
//    value       = "${azurerm_public_ip.staging_dynamic_public_base_ip.*.fqdn}"
// }
//
// output "azurerm_availability_set_id" {
//   description = "id of the  azurerm_availability_set_id"
//   value       = "${azurerm_availability_set.vm-as.*.id}"
// }


# output "availability_set_id" {
#   description = "id of the availability set where the vms are provisioned."
#   value       = "${azurerm_availability_set.vm-as.id}"
# }
//

// output "private_ip_dns" {
//   value = "${azurerm_private_dns_a_record.vm-dns.*.id}"
// }

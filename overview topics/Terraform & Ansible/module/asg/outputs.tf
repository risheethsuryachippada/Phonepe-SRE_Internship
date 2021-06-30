output "application_security_group_id" {
  description = "id of the security group provisioned"
  value       = "${azurerm_application_security_group.asg.id}"
}

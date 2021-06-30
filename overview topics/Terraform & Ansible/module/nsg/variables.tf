variable "resource_group_name" {}

variable "location" {}

variable "nsg_name" {}

variable "tags" {
  type        = map(string)
  default = {
    source = "terraform"
  }
}

variable "nsg_rule_name" {}

variable "description" {}

variable "priority" {}

variable "direction" {}

variable "access" {}

variable "protocol" {}

variable "source_port_range" {}

variable "destination_port_range" {}

variable "source_address_prefix" {}

variable "destination_address_prefix" {}

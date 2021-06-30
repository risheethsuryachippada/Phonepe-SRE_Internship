variable "resource_group_name" {
  default = ""
}


variable "location" {}

#variable "vnet_subnet_id" {}
variable "az_subnet_rg_name" {}

variable "az_vnet_name" {}

variable "az_subnet_name" {}

variable "public_ip_dns" {
  default = [""]
}

// variable "azurerm_private_dns_zone" {}
//
// variable "private_ip_dns" {
//  default     = []
// }

variable "availability_set_location" {
  default = ["South India", "Central India"]
}
variable "client_name" {
  default = ""
}

variable "region_name" {
  default = ""
}

variable "env_name" {
  description = "Environment name"
  default     = ""
}

variable "admin_password" {
  default = ""
}

// variable "network_security_group_id" {
//   description = "Resource id of the Virtual Network subnet"
//   type        = string
// }

variable "ssh_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "remote_port" {

}

variable "admin_username" {
  default = "azureuser" // ubuntu
}

variable "custom_data" {
  default = ""
}

variable "identity" {
  default = ""
}

variable "identity_type" {
  default = "UserAssigned"
}

variable "identity_ids" {
  default = []
}

variable "enable_azurerm_availability_set" {
  default = ""
}



variable "storage_account_type" {
  default = "Premium_LRS"
}

variable "vm_size" {
  default = "Standard_DS1_V2"
}

variable "instances_count" {
  default = "1"
}

variable "data_disk_count" {
  default = "1"
}

variable "lun_count" {
  default = "0"
}

variable "vm_hostname" {
  description = "local name of the VM"
  default     = "myvm"
}


variable "vm_os_id" {
  default = ""
}

variable "is_windows_image" {
  default = false
}

variable "vm_os_publisher" {
  default = ""
}

variable "vm_os_offer" {
  default = ""
}

variable "vm_os_sku" {
  default = ""
}

variable "vm_os_version" {
  default = "latest"
}

variable "tags" {
  type = map(string)
  default = {
    source= "terraform"
  }
}

variable "public_ip_address_allocation" {
  type    = bool
  default = false
}


variable "allocation_method" {
  default = "Dynamic"
}

variable "count_public_ip" {
  default = "0"
}

variable "delete_os_disk_on_termination" {
  type    = bool
  default = true
}

variable "delete_data_disks_on_termination" {
  type    = bool
  default = true
}

variable "data_sa_type" {
  default = "Standard_LRS"
}

variable "data_disk_size_gb" {
  default = ""
}

variable "os_disk_size_gb" {
  default = ""
}

variable "data_disk" {
  type    = bool
  default = false
}

variable "boot_diagnostics" {
  type    = bool
  default = false
}

variable "boot_diagnostics_storage_uri" {
  default = ""
}

variable "boot_diagnostics_sa_type" {
  default = "Standard_LRS"
}

variable "enable_accelerated_networking" {
  type    = bool
  default = false
}


//

variable "vm_os_simple" {
  default = ""
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default = {
    "UbuntuServer"  = "Canonical,UbuntuServer,16.04-LTS"
    "WindowsServer" = "MicrosoftWindowsServer,WindowsServer,2016-Datacenter"
    "RHEL"          = "RedHat,RHEL,7.5"
  }
}
//

variable "ip_config_file" {
  default = ""
}

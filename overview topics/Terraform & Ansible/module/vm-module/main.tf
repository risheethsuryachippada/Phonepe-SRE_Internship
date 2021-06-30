resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 8
}

# resource "azurerm_storage_account" "vm-sa" {
#   count                    = var.boot_diagnostics ? 1 : 0
#   name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
#   account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
#   tags                     = var.tags
# }


# Create network interface
resource "azurerm_network_interface" "staging_base_NIC" {
  name                = "nic-${var.vm_hostname}00${count.index + 1}"
  count               = var.instances_count
  location            = var.location
  resource_group_name = var.resource_group_name
  //network_security_group_id = var.network_security_group_id


  ip_configuration {
    name                          = "staging_base_NIC00${count.index + 1}"
    subnet_id                     = data.azurerm_subnet.stg-ins-subnet.id
    private_ip_address_allocation = "dynamic"
    # private_ip_address            = "${yamldecode(file("${var.ip_config_file}"))["${var.vm_hostname}00${count.index + 1}"]}"
    # public_ip_address_id          = length(azurerm_public_ip.staging_dynamic_public_base_ip.*.id) > 0 ? element(concat(azurerm_public_ip.staging_dynamic_public_base_ip.*.id, list("")), count.index) : ""
  }
}

# create availability set
resource "azurerm_availability_set" "staging_availability_set_1" {
  name     = "${var.vm_hostname}-availability-set"
  location = var.location
  #location            = var.availability_set_location[0]
  resource_group_name         = var.resource_group_name
  platform_fault_domain_count = 2
}
# resource "azurerm_availability_set" "staging_availability_set_2" {
#   name                = "availability-set-2"
#   location            = var.availability_set_location[1]
#   resource_group_name = var.resource_group_name
# }


# Create public IPs
# resource "azurerm_public_ip" "staging_dynamic_public_base_ip" {
#   count               = var.count_public_ip
#   name                = "${var.vm_hostname}-00${count.index + 1}-publicIP"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Dynamic" #coalesce(var.allocation_method, var.public_ip_address_allocation, "Dynamic")
# }

# NSG module
module "nsg" {
  source = "../../module/nsg"

  nsg_name            = "${var.vm_hostname}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags                       = var.tags
  nsg_rule_name              = "allow_remote_ports_in_all"
  description                = "Allow remote ssh protocol(22) in from all locations"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = var.remote_port
  source_address_prefix      = "Internet"
  destination_address_prefix = "*"
}

# ASG Module
module "asg" {
  source = "../../module/asg"

  asg_name            = "${var.vm_hostname}-asg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm-linux" {
  name                  = "${var.vm_hostname}00${count.index + 1}"
  location              = var.location
  count                 = var.instances_count
  resource_group_name   = var.resource_group_name
  network_interface_ids = ["${element(azurerm_network_interface.staging_base_NIC.*.id, count.index)}"]
  vm_size               = var.vm_size
  availability_set_id   = azurerm_availability_set.staging_availability_set_1.id
  #availability_set_id   = (count.index % 2) > 0 ? azurerm_availability_set.staging_availability_set_1.id : azurerm_availability_set.staging_availability_set_2.id
  // availability_set_id   = length(azurerm_availability_set.vm-as.*.id) > 0 ? element(concat(azurerm_availability_set.vm-as.*.id, list("")), count.index) : ""  #azurerm_availability_set.vm-as.id
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination


  storage_os_disk {
    name              = "osdisk-${var.vm_hostname}00${count.index + 1}"
    create_option     = "FromImage"
    caching           = "ReadOnly"
    disk_size_gb      = var.os_disk_size_gb
    managed_disk_type = var.storage_account_type
  }

  storage_image_reference {
    #id        =  var.vm_os_id
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  os_profile {
    computer_name  = "${var.vm_hostname}00${count.index + 1}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys" # need to use vault
      key_data = file(var.ssh_key)
    }
  }
  # plan {
  #   name      = "cis-ubuntu1804-l1"
  #   publisher = "center-for-internet-security-inc"
  #   product   = "cis-ubuntu-linux-1804-l1"
  # }

  tags = var.tags

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? var.boot_diagnostics_storage_uri : ""
  }


}

resource "azurerm_managed_disk" "data-disk" {
  count                = var.data_disk_count # ? 1 : 0
  name                 = "datadisk-${var.vm_hostname}00${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags
}
//

resource "azurerm_virtual_machine_data_disk_attachment" "data-disk-attachment" {
  count              = var.data_disk_count #  ? 1 : 0
  managed_disk_id    = "${element(azurerm_managed_disk.data-disk.*.id, count.index)}"
  virtual_machine_id = "${element(azurerm_virtual_machine.vm-linux.*.id, count.index)}"
  lun                = "${var.lun_count}${count.index}"
  caching            = "ReadOnly"
}

resource "azurerm_network_interface_security_group_association" "vm-nsg-security_group_association" {
  count                     = var.instances_count
  network_interface_id      = "${element(azurerm_network_interface.staging_base_NIC.*.id, count.index)}" # azurerm_network_interface.staging_base_NIC.id
  network_security_group_id = module.nsg.network_security_group_id
}

resource "azurerm_network_interface_application_security_group_association" "vm-asg-association" {
  count                         = var.instances_count
  network_interface_id          = "${element(azurerm_network_interface.staging_base_NIC.*.id, count.index)}"
  application_security_group_id = module.asg.application_security_group_id
}

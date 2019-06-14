#Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "=1.28.0"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
}

#================================================================================================================================#
#														Virtual Network							                                                                         #
#================================================================================================================================#
resource "azurerm_resource_group" "RG" {
  name     = "Network-RG"
  location = "South India"
}

resource "azurerm_network_security_group" "NSG" {
  name                = "Subnet_NSG"
  location            = "${azurerm_resource_group.RG.location}"
  resource_group_name = "${azurerm_resource_group.RG.name}"
}

resource "azurerm_network_security_rule" "RDP" {
  name                        = "RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "114.143.143.134,14.142.23.154"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = "${azurerm_resource_group.RG.name}"
  network_security_group_name = "${azurerm_network_security_group.NSG.name}"
}

resource "azurerm_network_security_group" "VM" {
  name                = "VM_NSG"
  location            = "${azurerm_resource_group.RG.location}"
  resource_group_name = "${azurerm_resource_group.RG.name}"
}

resource "azurerm_network_security_rule" "RDP_Server" {
  name                        = "RDP_Server"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "114.143.143.134,14.142.23.154"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = "${azurerm_resource_group.RG.name}"
  network_security_group_name = "${azurerm_network_security_group.VM.name}"
}

resource "azurerm_virtual_network" "test" {
  name                = "Production"
  location            = "${azurerm_resource_group.RG.location}"
  resource_group_name = "${azurerm_resource_group.RG.name}"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.5", "10.0.0.6"]

  subnet {
    name           = "Web"
    address_prefix = "10.0.1.0/24"
    security_group = "${azurerm_network_security_group.NSG.id}"
    
  }

  subnet {
    name           = "Backend"
    address_prefix = "10.0.2.0/24"
    security_group = "${azurerm_network_security_group.NSG.id}"
    }

  subnet {
    name           = "Database"
    address_prefix = "10.0.3.0/24"
    security_group = "${azurerm_network_security_group.NSG.id}"
    }

  tags = {
    environment = "Production"
  }
}

output "azurerm_virtual_network" {
  description = "id of the security group provisioned"
  value       = "${azurerm_virtual_network.test.*.id}"
}

variable "subnet_id" {
  default = "/subscriptions/4ea4b58b-041e-4e67-93c1-9f27600be849/resourceGroups/Network-RG/providers/Microsoft.Network/virtualNetworks/Production/subnets/Web"
}

variable "location" {
  default = "South India"
}

resource "azurerm_resource_group" "VM-RG" {
  name     = "VirtualMachine-RG"
  location = "South India"
}

#================================================================================================================================#
#														Key Vault    						                                                                         #
#================================================================================================================================#
# resource "azurerm_resource_group" "KeyVault-RG" {
#   name     = "KeyVault-RG"
#   location = "South India"
# }

# data "azurerm_client_config" "current" {}

# resource "azurerm_key_vault" "test" {
#   name                = "diskvault051"
#   location            = "${azurerm_resource_group.KeyVault-RG.location}"
#   resource_group_name = "${azurerm_resource_group.KeyVault-RG.name}"
#   tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

#   sku {
#     name = "premium"
#   }

#   access_policy {
#     tenant_id = "${data.azurerm_client_config.current.tenant_id}"
#     object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

#     key_permissions = [
#       "create",
#       "delete",
#       "get",
#     ]

#     secret_permissions = [
#       "delete",
#       "get",
#       "set",
#     ]
#   }

#   enabled_for_disk_encryption = true

#   tags {
#     environment = "Production"
#   }
# }

# resource "azurerm_key_vault_secret" "test" {
#   name      = "secret"
#   value     = "szechuan"
#   vault_uri = "${azurerm_key_vault.test.vault_uri}"
# }

# resource "azurerm_key_vault_key" "test" {
#   name      = "key"
#   vault_uri = "${azurerm_key_vault.test.vault_uri}"
#   key_type  = "EC"
#   key_size  = 2048

#   key_opts = [
#     "sign",
#     "verify",
#   ]
# }

# module "emptyDisk" {
#     source               = "Azure/encryptedmanageddisk/azurerm"
#     resource_group_name  = "${azurerm_resource_group.diskRg.name}"
#     disk_size_gb         = 1

#     keyVaultID           = "${azurerm_key_vault.test.id}"
#     secretURL            = "${azurerm_key_vault_secret.test.id}"
#     keyURL               = "${azurerm_key_vault_key.test.id}"
# }

# output "empty_disk_id" {
#   description = "The id of the newly created managed disk"  
#   value = "${module.emptyDisk.managed_disk_id}"
# }

#================================================================================================================================#
#														Public IPs       						                                                                         #
#================================================================================================================================#

# resource "azurerm_public_ip" "test" {
#   name                         = "publicIPForLB"
#   location                     = "${var.location}"
#   resource_group_name          = "${azurerm_resource_group.VM-RG.name}"
#   public_ip_address_allocation = "static"
# }

resource "azurerm_public_ip" "VM" {
  name                         = "publicIPForVM"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.VM-RG.name}"
  public_ip_address_allocation = "static"
}

#================================================================================================================================#
#														NICs  			                                                                                         #
#================================================================================================================================#

resource "azurerm_network_interface" "NIC" {
  count                     = 1
  name                      = "VMNIC${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.VM-RG.name}"
  network_security_group_id = "${azurerm_network_security_group.VM.id}"
  
  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id    = "${azurerm_public_ip.VM.id}"
    }
  }

#================================================================================================================================#
#														Disks  			                                                                                         #
#================================================================================================================================#

resource "azurerm_managed_disk" "VM-Disk" {
  count                = 1
  name                 = "datadisk_existing_${count.index}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.VM-RG.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}

#================================================================================================================================#
#														Virtual Machines                                                                                     #
#================================================================================================================================#

resource "azurerm_virtual_machine" "test" {
  count                 = 1
  name                  = "acctvm${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.VM-RG.name}"
  network_interface_ids = ["${element(azurerm_network_interface.NIC.*.id, count.index)}"]
  vm_size               = "Standard_B1s"
  #availability_set_id   = "${azurerm_availability_set.avset.id}"


  #================================================================================================================================#
  #														Disk Image  			                                                                                   #
  #================================================================================================================================#

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  # #Optional data disks 
  # storage_data_disk {
  #   name              = "datadisk_new_${count.index}"
  #   managed_disk_type = "Standard_LRS"
  #   create_option     = "Empty"
  #   lun               = 0
  #   disk_size_gb      = "10"
  # }
  # storage_data_disk {
  #   name            = "${element(azurerm_managed_disk.VM-Disk.*.name, count.index)}"
  #   managed_disk_id = "${element(azurerm_managed_disk.VM-Disk.*.id, count.index)}"
  #   create_option   = "Attach"
  #   lun             = 1
  #   disk_size_gb    = "${element(azurerm_managed_disk.VM-Disk.*.disk_size_gb, count.index)}"
  # }
  os_profile {
    computer_name  = "server"
    admin_username = "amit"
    admin_password = "Passw0rd1234"
  }
  #For windows uncomment below
  os_profile_windows_config {}

  # For Linux uncomment below
  # os_profile_linux_config {
  #   disable_password_authentication = false
  # }
}

#================================================================================================================================#
#														Availability Sets						                                 #
#================================================================================================================================#
# resource "azurerm_availability_set" "avset" {
#   name                         = "RDS"
#   location                     = "${var.location}"
#   resource_group_name          = "${azurerm_resource_group.VM-RG.name}"
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
# }


#================================================================================================================================#
#											                            Load Balancer   			                  			                                 #
#================================================================================================================================#


# resource "azurerm_public_ip" "ForLB" {
#   name                = "PublicIPForLB"
#   location            = "South India"
#   resource_group_name = "${azurerm_resource_group.VM-RG.name}"
#   allocation_method   = "Static"
# }


# resource "azurerm_lb" "test" {
#   name                = "TestLoadBalancer"
#   location            = "South India"
#   resource_group_name = "${azurerm_resource_group.VM-RG.name}"


#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = "${azurerm_public_ip.ForLB.id}"
#   }
# }


#================================================================================================================================#
#											                            diagnostic Storage Account               			                                 #
#================================================================================================================================#


resource "azurerm_resource_group" "Storage-RG" {
  name     = "Storage-RG"
  location = "South India"
}


resource "azurerm_storage_account" "testdiagaccount" {
  name                     = "testdiagaccount"
  resource_group_name      = "${azurerm_resource_group.Storage-RG.name}"
  location                 = "${azurerm_resource_group.Storage-RG.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    ip_rules                   = ["14.142.23.154"]
    virtual_network_subnet_ids = ["${var.subnet_id}"]
  }
  

  tags = {
    environment = "Prod"
  }
}


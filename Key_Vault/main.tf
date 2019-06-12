resource "azurerm_resource_group" "KeyVault-RG" {
  name     = "KeyVault-RG"
  location = "South India"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                = "diskvault051"
  location            = "${azurerm_resource_group.KeyVault-RG.location}"
  resource_group_name = "${azurerm_resource_group.KeyVault-RG.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "premium"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

    key_permissions = [
      "create",
      "delete",
      "get",
    ]

    secret_permissions = [
      "delete",
      "get",
      "set",
    ]
  }

  enabled_for_disk_encryption = true

  tags {
    environment = "Production"
  }
}

resource "azurerm_key_vault_secret" "test" {
  name      = "secret"
  value     = "szechuan"
  vault_uri = "${azurerm_key_vault.test.vault_uri}"
}

resource "azurerm_key_vault_key" "test" {
  name      = "key"
  vault_uri = "${azurerm_key_vault.test.vault_uri}"
  key_type  = "EC"
  key_size  = 2048

  key_opts = [
    "sign",
    "verify",
  ]
}

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
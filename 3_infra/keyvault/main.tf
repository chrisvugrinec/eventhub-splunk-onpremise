resource "azurerm_resource_group" "kv-rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}


# keyvault
resource "azurerm_key_vault" "devops-kv" {
  name                            = "${var.keyvault-name}"
  location                        = "${azurerm_resource_group.kv-rg.location}"
  resource_group_name             = "${azurerm_resource_group.kv-rg.name}"
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tenant_id                       = "${var.tenant_id}"

  sku_name = "standard"

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.object_user_id}"

    key_permissions = [
      "get", "list", "create", "delete"
    ]

    secret_permissions = [
      "get", "list", "set", "delete"
    ]
  }

  # Change this to Deny, for limited network access
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  depends_on          = ["azurerm_resource_group.kv-rg"]
}


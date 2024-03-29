resource "azurerm_resource_group" "network-rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "mgmt-vnet" {
  name                = "${var.vnet}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.network-rg.location}"
  resource_group_name = "${azurerm_resource_group.network-rg.name}"
}

resource "azurerm_subnet" "mgmt-subnet" {
  name                 = "${var.subnet}"
  resource_group_name  = "${azurerm_resource_group.network-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.mgmt-vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

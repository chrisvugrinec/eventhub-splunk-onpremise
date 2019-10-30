resource "azurerm_resource_group" "eh-rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}



resource "azurerm_eventhub_namespace" "eh-splunk-demo" {
  name                = "eh-splunk-demo-eh-ns"
  location            = "${azurerm_resource_group.eh-rg.location}"
  resource_group_name = "${azurerm_resource_group.eh-rg.name}"
  sku                 = "Standard"
  capacity            = 1
  kafka_enabled       = false

  tags = {
    environment = "demo"
  }
}

resource "azurerm_eventhub" "eh-splunk-demo" {
  name                = "eh-splunk-demo-eh-ns"
  namespace_name      = "${azurerm_eventhub_namespace.eh-splunk-demo.name}"
  resource_group_name = "${azurerm_resource_group.eh-rg.name}"
  partition_count     = 2
  message_retention   = 1
}

locals {
  name-convention = "${var.environment}${var.location}${var.tier}_ehsplunkdemo}"
}

# This is a shared Component
module "network" {
  source   = "./network"
  rg       = var.rg_main
  location = var.location_main
  vnet     = var.vnet
  subnet   = var.subnet
}

module "keyvault" {
  source         = "./keyvault"
  tenant_id      = var.TENANT_ID
  object_user_id = var.OBJECT_USER_ID
  rg             = var.rg_main
  location       = var.location_main
  keyvault-name  = "devops-kv-${random_string.random-namespace.result}"
}

module "eventhub" {
  source         = "./eventhub"
  rg             = var.rg_main
  location       = var.location_main
}

module "vm-splunk1" {
  source    = "./vm-splunk1"
  static_ip = "10.0.2.5"
  ssh       = var.SSH
  rg        = var.rg_main
  location  = var.location_main
  hostname  = "splunk1"
  vnet      = var.vnet
  subnet    = var.subnet
  keyvault  = "devops-kv-${random_string.random-namespace.result}"
}

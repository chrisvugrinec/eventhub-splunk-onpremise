resource "random_string" "random-namespace" {
  length  = 10
  special = false
}

variable "tags" {
  type = "map"
  default = {
    environment = "demo"
    source      = "microsoft"
  }
}

variable "environment" {
  default = "dev"
}

variable "tier" {
  default = "1"
}


variable "location" {
  default = "australiaeast"
}

variable "location_main" {
  default = "australiaeast"
}

variable "rg_main" {
  default = "eh-splunk-demo"
}

variable "location_team" {
  default = "australiaeast"
}

variable "vnet" {
  default = "mgmt-vnet"
}

variable "subnet" {
  default = "mgmt-subnet"
}

variable "CLIENT_ID" {} 
variable "CLIENT_SECRET" {} 
variable "TENANT_ID" {}
# This is the Object ID for the ID from the operator
variable "OBJECT_USER_ID" {}
variable "SSH" {}

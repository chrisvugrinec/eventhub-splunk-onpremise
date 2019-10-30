variable "vm_size" {
  default = "Standard_DS3_v2"
}
variable "image-rg" {
  default = "eh-splunk-demo-image"
}
variable "ssh" {}
variable "static_ip" {}
variable "hostname" {}
variable "rg" {}
variable "location" {}
variable "vnet" {}
variable "subnet" {}
variable "keyvault" {}

resource "azurerm_resource_group" "vm-rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}

data "azurerm_virtual_network" "mgmt-vnet" {
  name                = "${var.vnet}"
  resource_group_name = "${azurerm_resource_group.vm-rg.name}"
  depends_on = ["azurerm_resource_group.vm-rg"]
}

data "azurerm_subnet" "mgmt-subnet" {
  name                 = "${var.subnet}"
  resource_group_name  = "${azurerm_resource_group.vm-rg.name}"
  virtual_network_name = "${data.azurerm_virtual_network.mgmt-vnet.name}"
  depends_on = ["azurerm_resource_group.vm-rg"]
}


resource "azurerm_public_ip" "devops-pip" {
  name                    = "${var.hostname}-devops-pip"
  location                = "${azurerm_resource_group.vm-rg.location}"
  resource_group_name     = "${azurerm_resource_group.vm-rg.name}"
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}-nic"
  location            = "${azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${azurerm_resource_group.vm-rg.name}"

  ip_configuration {
    name                          = "devops-ipconfig"
    subnet_id                     = "${data.azurerm_subnet.mgmt-subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.static_ip}"
    public_ip_address_id          = "${azurerm_public_ip.devops-pip.id}"
  }
}

data "azurerm_image" "custom" {
  name                = "splunkvm-image"
  resource_group_name = "${var.image-rg}"
}

resource "azurerm_virtual_machine" "buildagent" {
  name                  = "${var.hostname}"
  location              = "${azurerm_resource_group.vm-rg.location}"
  resource_group_name   = "${azurerm_resource_group.vm-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "${var.vm_size}"


  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "buildagent"
    admin_username = "vagrant"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/vagrant/.ssh/authorized_keys"
      key_data = "${var.ssh}"
    }
  }
}


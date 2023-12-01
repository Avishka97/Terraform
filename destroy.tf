resource "azurerm_resource_group" "main1" {
  name = "${var.prefix}-resourcegroup"
}

resource "azurerm_virtual_network" "main1" {
  name                = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal1" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
}

resource "azurerm_public_ip" "pip1" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_interface" "main1" {
  name                = "${var.prefix}-nic1"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_interface" "internal1" {
  name                = "${var.prefix}-nic2"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_group" "webserver1" {
  name                = "tls_webserver"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_interface_security_group_association" "main1" {
  network_interface_id      = azurerm_network_interface.internal.id
}

resource "azurerm_windows_virtual_machine" "main1" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.main.name
}

resource "null_resource" "destroy_resources" {
  triggers = {
    destroy = timestamp()
  }

  provisioner "local-exec" {
    command = "terraform destroy -auto-approve"
  }
}

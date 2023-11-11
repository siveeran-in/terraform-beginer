resource "azurerm_resource_group" "web" {
  name  =   "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "web" {
  name                = "${var.prefix}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name
}

resource "azurerm_subnet" "web" {
  name                 = "${var.prefix}-sn"
  resource_group_name  = azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.web.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "web" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "web" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.web.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "file" {
    source = "web.sh"
    destination = "/tmp/web.sh"
    connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = self.public_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod  +x /tmp/web.sh",
      "sudo /tmp/web.sh",
    ]
    connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = self.public_ip_address
    }
  }
}
resource "azurerm_resource_group" "example" {
  name  =   "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "${var.prefix}-sn"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
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
    provisioner "local-exec" {
    command = "echo ${self.public_ip_address} > myfile"
  }

  provisioner "local-exec" {
    command = "echo sleep 10 > script.sh ; echo echo Starting... >> script.sh ; echo sleep 10 >> script.sh ; echo echo I am coming from script >> script.sh ; echo sleep 10 >> script.sh ; echo echo Finishing... >> script.sh "
  }

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
    connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = self.public_ip_address
    }
  }


  provisioner "remote-exec" {
    inline = [
      "chmod  x /tmp/script.sh",
      "/bin/sh /tmp/script.sh",
    ]
    connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = self.public_ip_address
    }
  }
}
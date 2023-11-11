resource "azurerm_resource_group" "example" {
  name  =   "${var.prefix}-${terraform.workspace}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-${terraform.workspace}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "${var.prefix}-${terraform.workspace}-sn"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  count = "${ terraform.workspace == "prd" ? 2 : terraform.workspace == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${terraform.workspace}-${count.index}-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  count = "${ terraform.workspace == "prd" ? 2 : terraform.workspace == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${terraform.workspace}-${count.index}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  count = "${ terraform.workspace == "prd" ? 2 : terraform.workspace == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${terraform.workspace}-${count.index}-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "${ terraform.workspace == "prd" ? "Standard_F2" : terraform.workspace == "dev" ? "Standard_F1" : "Standard_B1s" }" 
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
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
}
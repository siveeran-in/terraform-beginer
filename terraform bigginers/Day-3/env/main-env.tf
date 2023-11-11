data "template_file" "env" {
  template = file("${path.module}/myenv.txt")
  #template =  file("C:\Users\SivaNagaRajuVeeranki\Downloads\before kyndryl os installation\courses\terraform\terraform bigginers\Day-3\env\myenv.txt")
}

resource "azurerm_resource_group" "example" {
  count = "${ trimspace(data.template_file.env.rendered) == "prd" ? 2 : trimspace(data.template_file.env.rendered) == "dev" ? 1 : 0 }"
  name  =   "${var.prefix}-${count.index}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  count = "${ trimspace(data.template_file.env.rendered) == "prd" ? 2 : trimspace(data.template_file.env.rendered) == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${count.index}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example[count.index].location
  resource_group_name = azurerm_resource_group.example[count.index].name
}

resource "azurerm_subnet" "example" {
  count = "${ trimspace(data.template_file.env.rendered) == "prd" ? 2 : trimspace(data.template_file.env.rendered) == "dev" ? 1 : 0 }"
  name                 = "${var.prefix}-${count.index}-sn"
  resource_group_name  = azurerm_resource_group.example[count.index].name
  virtual_network_name = azurerm_virtual_network.example[count.index].name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  count = "${ trimspace(data.template_file.env.rendered) == "prd" ? 2 : trimspace(data.template_file.env.rendered) == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${count.index}-pip"
  resource_group_name = azurerm_resource_group.example[count.index].name
  location            = azurerm_resource_group.example[count.index].location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  count = "${ trimspace(data.template_file.env.rendered) == "prd" ? 2 : trimspace(data.template_file.env.rendered) == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${count.index}-nic"
  location            = azurerm_resource_group.example[count.index].location
  resource_group_name = azurerm_resource_group.example[count.index].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  count = "${ trimspace(data.template_file.env.rendered) == "prd" ? 2 : trimspace(data.template_file.env.rendered) == "dev" ? 1 : 0 }"
  name                = "${var.prefix}-${count.index}-vm"
  resource_group_name = azurerm_resource_group.example[count.index].name
  location            = azurerm_resource_group.example[count.index].location
  size                = "${ trimspace(data.template_file.env.rendered) == "prd" ? "Standard_F2" : trimspace(data.template_file.env.rendered) == "dev" ? "Standard_F1" : "Standard_B1s" }"
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
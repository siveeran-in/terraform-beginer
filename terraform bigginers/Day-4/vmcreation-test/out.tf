output "MyPublicIP" {
  value = azurerm_linux_virtual_machine.web.public_ip_address
}
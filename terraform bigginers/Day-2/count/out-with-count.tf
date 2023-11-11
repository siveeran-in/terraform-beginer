output "MyPublicIP" {
  value = azurerm_linux_virtual_machine.example[*].public_ip_address
}

output "MyPublicIP0" {
  value = azurerm_linux_virtual_machine.example[0].public_ip_address
}

output "MyPublicIP1" {
  value = azurerm_linux_virtual_machine.example[1].public_ip_address
}

output "MyPublicIP2" {
  value = azurerm_linux_virtual_machine.example[2].public_ip_address
}
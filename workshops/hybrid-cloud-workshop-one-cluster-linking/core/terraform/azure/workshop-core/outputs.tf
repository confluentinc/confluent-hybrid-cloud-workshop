output "external_ip_addresses" {
  value = data.azurerm_public_ip.instance.*.ip_address
}

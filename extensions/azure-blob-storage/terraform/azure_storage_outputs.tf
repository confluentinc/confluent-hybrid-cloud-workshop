output "storage_account_access_keys" {
  depends_on = [azurerm_storage_account.instance]
  value      = data.azurerm_storage_account.instance.*.primary_access_key
}

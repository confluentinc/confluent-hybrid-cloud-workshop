// Azure storage accounts
locals {
  common_tags = {
    project  = "workshop-framework"
  }
  extra_tags  = {
    workshop-name = "${var.name}"
  }
}
resource "azurerm_storage_account" "instance" {
  depends_on               = [module.workshop-core]
  name                     = "${var.name}bstore"
  resource_group_name      = "${var.name}-resources"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = merge( local.common_tags, local.extra_tags)
}

data "azurerm_storage_account" "instance" {
  depends_on          = [azurerm_storage_account.instance]
  name                = "${var.name}bstore"
  resource_group_name = azurerm_storage_account.instance.resource_group_name
}

// Azure storage containers
resource "azurerm_storage_container" "instance" {
  name                  = "container"
  #count                 = "${var.participant_count}"
  storage_account_name  = azurerm_storage_account.instance.name
  container_access_type = "private"
}

resource "null_resource" "add_vars_azure_storage" {
  depends_on = [data.azurerm_storage_account.instance]
  count      = var.participant_count

  provisioner "remote-exec" {
    inline = [
      "echo 'AZURE_STORAGE_ACCOUNT_NAME=${data.azurerm_storage_account.instance.name}' >> ~/.workshop/docker/.env",
      "echo 'AZURE_STORAGE_ACCOUNT_KEY=${data.azurerm_storage_account.instance.primary_access_key}' >> ~/.workshop/docker/.env",
      "echo 'AZURE_STORAGE_CONTAINER=${azurerm_storage_container.instance.name}' >> ~/.workshop/docker/.env"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}

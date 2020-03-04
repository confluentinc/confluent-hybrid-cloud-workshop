provider "azurerm" {
  version         = "~> 1.35"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

provider "random" {
  version = "~> 2.2"
}

module "workshop-core" {
  source                    = "./workshop-core"
  name                      = "${var.name}"
  participant_count         = "${var.participant_count}"
  participant_password      = "${var.participant_password}"
  location                  = "${var.location}"
  vm_type                   = "${var.vm_type}"
  ccloud_bootstrap_servers  = "${var.ccloud_bootstrap_servers}"
  ccloud_api_key            = "${var.ccloud_api_key}"
  ccloud_api_secret         = "${var.ccloud_api_secret}"
  ccloud_topics            = "${var.ccloud_topics}"
}


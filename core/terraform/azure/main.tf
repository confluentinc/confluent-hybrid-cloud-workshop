provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

provider "random" {
}

module "workshop-core" {
  source                    = "./workshop-core"
  name                      = var.name
  participant_count         = var.participant_count
  participant_password      = var.participant_password
  owner_email               = var.owner_email
  location                  = var.location
  vm_type                   = var.vm_type
  vm_disk_size              = var.vm_disk_size
  ccloud_bootstrap_servers  = var.ccloud_bootstrap_servers
  ccloud_api_key            = var.ccloud_api_key
  ccloud_api_secret         = var.ccloud_api_secret
  ccloud_topics             = var.ccloud_topics
  onprem_topics             = var.onprem_topics
  feedback_form_url         = var.feedback_form_url
}


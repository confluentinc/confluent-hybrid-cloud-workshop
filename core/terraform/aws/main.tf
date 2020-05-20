provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "workshop-core" {
  source                   = "./workshop-core"
  name                     = var.name
  participant_count        = var.participant_count
  participant_password     = var.participant_password
  region                   = var.region
  vm_type                  = var.vm_type
  ami                      = var.ami
  ccloud_bootstrap_servers = var.ccloud_bootstrap_servers
  ccloud_api_key           = var.ccloud_api_key
  ccloud_api_secret        = var.ccloud_api_secret
  ccloud_topics            = var.ccloud_topics
  feedback_form_url        = var.feedback_form_url
}
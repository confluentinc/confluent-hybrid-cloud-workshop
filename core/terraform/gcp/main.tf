/*
 Providers
*/
provider "google" {
  credentials = var.credentials_file_path
  project     = var.project
  region      = var.region
}

module "workshop-core" {
  source                   = "./workshop-core"
  name                     = var.name
  participant_count        = var.participant_count
  participant_password     = var.participant_password
  region                   = var.region
  region_zone              = var.region_zone
  project                  = var.project
  credentials_file_path    = var.credentials_file_path
  vm_type                  = var.vm_type
  ccloud_bootstrap_servers = var.ccloud_bootstrap_servers
  ccloud_api_key           = var.ccloud_api_key
  ccloud_api_secret        = var.ccloud_api_secret
  ccloud_topics            = var.ccloud_topics
  feedback_form_url        = var.feedback_form_url
}

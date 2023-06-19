/*
 Providers
*/
provider "google" {
  credentials = var.credentials_file_path
  project     = var.project
  region      = var.region
}

module "workshop-core" {
  source                   = "workshop-core"
  name                     = var.name
  participant_count        = var.participant_count
  participant_password     = var.participant_password
  region                   = var.region
  region_zone              = var.region_zone
  project                  = var.project
  credentials_file_path    = var.credentials_file_path
  vm_type                  = var.vm_type
  vm_disk_size             = var.vm_disk_size
  ccloud_bootstrap_servers = module.workshop-confluent-core.boostrap
  ccloud_api_key           = module.workshop-confluent-core.cluster_api_key
  ccloud_api_secret        = module.workshop-confluent-core.cluster_api_secret
  ccloud_cluster_id        = module.workshop-confluent-core.cluster_id
  ccloud_rest_endpoint     = module.workshop-confluent-core.rest_endpoint
#  ccloud_topics            = var.ccloud_topics
  onprem_topics            = var.onprem_topics
  feedback_form_url        = var.feedback_form_url
  owner_email              = var.owner_email
  purpose                  = var.purpose
  ref_link                 = var.ref_link
}

module "workshop-confluent-core" {
  source                   = "././common/confluent-cloud"
  ccloud_api_key           = var.ccloud_api_key
  ccloud_api_secret        = var.ccloud_api_secret
  ccloud_cluster_name      = var.ccloud_cluster_name
  ccloud_env_name          = var.ccloud_env_name
  region                   = var.region
  participant_count        = var.participant_count
  ccloud_topics            = var.ccloud_topics
  ccloud_sr_region         = var.ccloud_sr_region
  ccloud_package_sg        = var.ccloud_package_sg
  cloud_provider           = var.cloud_provider
  ccloud_cluster_availability_type = var.ccloud_cluster_availability_type
  name                      = var.name
}

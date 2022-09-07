provider "aws" {
  region     = var.region
  #access_key = var.access_key
  #secret_key = var.secret_key
  shared_credentials_files  = [var.credentials_file]
  profile = var.profile
  default_tags {
      tags = {
          owner_email = var.owner_email
          purpose = var.purpose
          ref_link = var.ref_link
      }
  }
}

module "workshop-core" {
  source                   = "./workshop-core"
  name                     = var.name
  participant_count        = var.participant_count
  participant_password     = var.participant_password
  region                   = var.region
  vm_type                  = var.vm_type
  vm_disk_size             = var.vm_disk_size
  ami                      = var.ami
  ccloud_bootstrap_servers = var.ccloud_bootstrap_servers
  ccloud_api_key           = var.ccloud_api_key
  ccloud_api_secret        = var.ccloud_api_secret
  ccloud_topics            = var.ccloud_topics
  onprem_topics            = var.onprem_topics
  feedback_form_url        = var.feedback_form_url
}
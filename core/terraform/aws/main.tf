provider "aws" {
  default_tags {
       tags = {
        owner: var.owner_email,
        owner_email: var.owner_email,
        Deployed_By: "Terraform"
    }
  }
  region     = var.region
  profile    = var.profile
  #access_key = var.access_key #because gimme-aws-creds doesnt require this
  #secret_key = var.secret_key #because gimme-aws-creds doesnt require this
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
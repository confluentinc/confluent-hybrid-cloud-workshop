provider "aws" {
  region     = var.region
  profile    = var.profile
  default_tags {
      tags = {
          owner_email = var.owner_email
          purpose     = var.purpose
          deployed_By = "Terraform"
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
  availability_zones       = var.availability_zones
}
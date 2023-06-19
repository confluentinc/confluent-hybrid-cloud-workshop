/*
  workshop-core variables
*/

variable "name" {
  description = "The Prefix used for all resources in this example"
}

variable "participant_count" {
  description = "How number of participants attending the workshop"
  type        = number
}

variable "participant_password" {
  description = "SSH password for the participant"
}

variable "project" {
  description = "GCP Project to use."
}

variable "region" {
  default = "us-central1"
}

variable "region_zone" {
  default = "us-central1-f"
}

variable "credentials_file_path" {
  description = "Credentials file location"
}

variable "vm_type" {
  description = "VM Type"
}

variable "vm_disk_size" {
  description = "VM Disk Size"
}

// Confluent Cloud variables
#variable "ccloud_bootstrap_servers" {
#  description = "Confluent Cloud username"
#}

variable "ccloud_api_key" {
  description = "Confluent Cloud password"
}

variable "ccloud_api_secret" {
  description = "Confluent Cloud Provider"
}

variable "ccloud_topics" {
  description = "Confluent Cloud topics to precreate"
}

variable "onprem_topics" {
  description = "Confluent Server on-prem topics to precreate"
}

variable "feedback_form_url" {
  description = "Feedback Form Url"
  default = ""
}

variable "purpose" {
  description = "Workshop purpose tag"
}

variable "ref_link" {
  description = "Workshop github repo tag"
  default = ""
}

variable "owner_email" {
  description = "Confluent owners email address for resource tagging"
}

variable "ccloud_env_name" {
  description = "Confluent cloud environment name"
}

variable "ccloud_cluster_name" {
  description = "Confluent cloud cluster name"
}

variable "ccloud_cluster_availability_type" {
  description = "Confluent cloud cluster type availability_type"
  default = "SINGLE_ZONE"
}

variable "ccloud_sr_region" {
  description = "Schema registry region"
  default = "eu-central-1"
}

variable "ccloud_package_sg" {
  description = "Stream Governance package type"
  default = "ESSENTIALS"
}

variable "cloud_provider" {
  description = "Cloud provider"
}
// Workshop variables
variable "name" {
  description = "The Prefix used for all resources in this example"
}

variable "participant_count" {
  description = "How many instances of this sample you want to create?"
  type        = number
}

variable "participant_password" {
  description = "Password for the admin user, to log in from ssh"
}

// GCP variables
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
variable "ccloud_bootstrap_servers" {
  description = "Confluent Cloud username"
}

variable "ccloud_api_key" {
  description = "Confluent Cloud password"
}

variable "ccloud_api_secret" {
  description = "Confluent Cloud Provider"
}

#variable "ccloud_topics" {
#  description = "Confluent Cloud topics to precreate"
#}

variable "onprem_topics" {
  description = "Confluent Server on-prem topics to precreate"
}

variable "feedback_form_url" {
  description = "Feedback Form Url"
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
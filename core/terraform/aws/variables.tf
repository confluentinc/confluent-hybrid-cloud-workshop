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

variable "region" {
  default = "us-central1"
}

variable "vm_type" {
  description = "VM Type"
}

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
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

variable "ccloud_topics" {
  description = "Confluent Cloud topics to precreate"
}

variable "feedback_form_url" {
  description = "Feedback Form Url"
  default = ""
}
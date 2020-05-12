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

// AWS variables
variable "region" {
  default = "us-central1"
}

variable "vm_type" {
  description = "VM Type"
}

variable "ami" {
  description = "Amazon Machine Image"
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
}
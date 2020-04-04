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

# VM Variables

variable "tenant_id" {
  description = "Tenant ID"
}

variable "subscription_id" {
  description = "Subscription ID"
}

variable "client_id" {
  description = "Client ID"
}

variable "client_secret" {
  description = "Client Secret"
}

variable "vm_type" {
  description = "VM Type"
}

variable "location" {
  description = "Location"
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

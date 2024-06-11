variable "name" {
  description = "The Prefix used for all resources in this example"
}

variable "participant_count" {
  description = "How number of participants attending the workshop"
  type        = number
}

variable "participant_password" {
  description = "Password for the admin user, to log in from ssh"
}


# VM Variables
variable "vm_type" {
  description = "VM Type"
}

variable "vm_disk_size" {
  description = "VM Disk Size"
}

variable "location" {
  description = "Location"
}

# CCloud Variables
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

variable "ccloud_cluster_id" {
  description = "Confluent Cloud Cluster ID"
}

variable "ccloud_rest_endpoint" {
  description = "Confluent Cloud REST endpoint"
}

variable "cluster_linking" {
  description = "cluster linking scenario to deploy"
  type        = number
  default     = 1
  validation {
    condition = contains([1, 0], var.cluster_linking)
    error_message = "Valid value is one of the following: 1, 0."
  }
}

variable "replicator" {
  description = "If set to true and var.cluster_linking is set to 0, it will create the workshop with replicator"
  type        = bool
  default     = false
}
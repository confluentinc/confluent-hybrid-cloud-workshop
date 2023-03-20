// Workshop variables
variable "ccloud_api_key" {
  description = "Confluent Cloud password"
}

variable "ccloud_api_secret" {
  description = "Confluent Cloud Provider"
}

variable "ccloud_cluster_name" {
  description = "Confluent cloud cluster name"
}
variable "region" {
  default = "us-central1"
}

variable "ccloud_cluster_availability_type" {
  description = "Confluent cloud cluster type availability_type"
  default = "SINGLE_ZONE"
}

variable "ccloud_topics" {
  description = "Confluent Cloud topics to precreate"
  default =""
}

variable "participant_count" {
  description = "How number of participants attending the workshop"
  type        = number
  default     = 1
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

variable "name" {
  description = "The Prefix used for all resources in this example"
}

locals {
  product = setproduct(range(1,var.participant_count+1,1), split(",",var.ccloud_topics))
}
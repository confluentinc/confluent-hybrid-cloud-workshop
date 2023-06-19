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

variable "vm_disk_size" {
  description = "VM Disk Size"
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

#variable "ccloud_topics" {
#  description = "Confluent Cloud topics to precreate"
#}

variable "onprem_topics" {
  description = "Confluent Server local on-prem to precreate"
}

variable "feedback_form_url" {
  description = "Feedback Form Url"
}

variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "List of public subnet CIDR blocks"
}

variable "availability_zones" {
  type        = list
  description = "List of availability zones"
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
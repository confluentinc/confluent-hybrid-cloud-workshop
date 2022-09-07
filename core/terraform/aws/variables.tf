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

variable "vm_disk_size" {
  description = "VM Disk Size"
}

variable "ami" {
  description = "Amazon Machine Image"
}

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

variable "aws_vpc_id" {
  description = "AWS VPC ID"
  default = ""
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

variable "onprem_topics" {
  description = "Confluent Server onprem topics to precreate"
}

variable "feedback_form_url" {
  description = "Feedback Form Url"
  default = ""
}

variable "owner_email" {
  description = "Workshop owner email tag"
}

variable "purpose" {
  description = "Workshop purpose tag"
}

variable "ref_link" {
  description = "Workshop github repo tag"
}

variable "credentials_file" {
  description = "path where aws credentials are located"
  default = ""
}

variable "profile" {
  description = "aws profile"
  default = ""
}
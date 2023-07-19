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


#variable "ccloud_topics" {
#  description = "Confluent Cloud topics to precreate"
#}


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

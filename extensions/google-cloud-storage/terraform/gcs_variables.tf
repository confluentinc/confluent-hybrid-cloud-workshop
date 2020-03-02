# variable "name" {
#   description = "The Prefix used for all resources in this example"
# }

# variable "participant_count" {
#   description = "How many instances of this sample you want to create?"
#   type        = number
# }

variable "gcs_project" {
  description = "GCP Project to use."
}

variable "gcs_region" {
  description = "The region for the GCS bucket"
}

# variable "gcs_storage_class" {
#   default = "REGIONAL"
# }

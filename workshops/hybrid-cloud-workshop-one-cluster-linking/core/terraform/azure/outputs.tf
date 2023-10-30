output "external_ip_addresses" {
  value = module.workshop-core.external_ip_addresses
}

output "topic" {
  value = module.workshop-confluent-core.topics
}

output "validate_versioning" {
  value = null

  precondition {
    condition     = (((var.cluster_linking == 1) && (var.replicator == false)) || ((var.cluster_linking == 0) && (var.replicator == false)) || ((var.cluster_linking == 0) && (var.replicator == true)))
    error_message = "replicator variable could be true just when var.cluster_linking = 0"
  }
}
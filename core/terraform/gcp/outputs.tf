output "external_ip_addresses" {
  value = module.workshop-core.external_ip_addresses
}
output "topic" {
  value = module.workshop-confluent-core.topics
}


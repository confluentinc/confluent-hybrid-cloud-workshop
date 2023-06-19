output "external_ip_addresses" {
  value = module.workshop-core.external_ip_addresses
}

output "external_hq_ip_address" {
  value = module.workshop-core.external_hq_ip_address
}

output "security_group_id" {
  value = module.workshop-core.security_group_id
}

output "subnet" {
  value = module.workshop-core.subnet
}

output "topic" {
  value = module.workshop-confluent-core.topics
}

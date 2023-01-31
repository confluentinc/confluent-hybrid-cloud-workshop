output "external_ip_addresses" {
  value = module.workshop-core.external_ip_addresses
}

output "security_group_id" {
  value = module.workshop-core.security_group_id
}

output "subnet_group_id" {
  value = module.workshop-core.subnet_group_id
}

output "topic" {
  value = module.workshop-confluent-core.topics
}

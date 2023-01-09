output "external_ip_addresses" {
  value = module.cloud-services.external_ip_addresses
}

output "security_group_id" {
  value = module.cloud-services.security_group_id
}

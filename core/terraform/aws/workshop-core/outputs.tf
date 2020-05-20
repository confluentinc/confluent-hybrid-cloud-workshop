output "external_ip_addresses" {
  value = aws_instance.instance.*.public_ip
}

output "security_group_id" {
  value = aws_security_group.instance.id
}
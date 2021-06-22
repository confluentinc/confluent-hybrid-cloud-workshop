output "external_ip_addresses" {
  value = aws_instance.instance.*.public_ip
}

output "security_group_id" {
  value = aws_security_group.instance.id
}

output "ws_iam_user_name" {
  value = aws_iam_user.ws.name
}
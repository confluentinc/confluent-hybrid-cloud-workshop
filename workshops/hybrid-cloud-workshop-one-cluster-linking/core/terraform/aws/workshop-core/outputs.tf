output "external_ip_addresses" {
  value = aws_instance.instance.*.public_ip
}

output "external_hq_ip_address" {
  value = aws_instance.hq_instance.*.public_ip
}


output "security_group_id" {
  value = aws_security_group.instance.id
}

output "subnet" {
  value = aws_subnet.workshop-public-subnet.*.id
}

/*output "ws_iam_user_name" {
  value = aws_iam_user.ws.name
}*/
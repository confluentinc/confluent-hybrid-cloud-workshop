output "external_ip_addresses" {
  value = "${aws_instance.instance.*.public_ip}"
}

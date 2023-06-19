output "dynamodb_table_name" {
  value      = data.template_file.dynamodb_table_name.rendered
}

output "dynamodb_region" {
  value      = var.region
}

output "dynamodb_endpoint" {
  value      = "https://dynamodb.${var.region}.amazonaws.com"
}

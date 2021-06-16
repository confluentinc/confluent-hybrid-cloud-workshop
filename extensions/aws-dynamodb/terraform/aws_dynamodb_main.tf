resource "aws_redshift_cluster" "instance" {
  cluster_identifier  = "${var.name}-rs-cluster"
  database_name       = "${var.name}db"
  master_username     = var.rs_username
  master_password     = var.rs_password
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  port                = 5539
  number_of_nodes     = 1
  skip_final_snapshot = true
  publicly_accessible = false
  vpc_security_group_ids = [module.workshop-core.security_group_id]
}

resource "random_string" "dynamodb_random_string" {
  length = 3
  special = false
  upper = false
  lower = true
  number = false
}

data "template_file" "dynamodb_table_name" {
  template = "${var.name}-orders-table-${random_string.dynamodb_random_string.result}"
}



resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = data.template_file.dynamodb_table_name.rendered
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "customer_id"
  range_key      = "id"

  attribute {
    name = "customer_id"
    type = "N"
  }

  attribute {
    name = "dc"
    type = "S"
  }

  attribute {
    name = "spent_sum"
    type = "S"
  }

  attribute {
    name = "product_name"
    type = "S"
  }

  attribute {
    name = "orders_count"
    type = "N"
  }


  tags = {
    Name        = "demo-aws-confluent"
  }
}


resource "local_file" "dynamodb_endpoint" {

  content  = <<EOF
DYNAMODB_TABLENAME=${aws_dynamodb_table.basic-dynamodb-table.name}
DYNAMODB_REGION=${var.region}
DYNAMODB_ENDPOINT=https://dynamodb.${var.region}.amazonaws.com
EOF
  filename = "${path.module}/dynamodb_conn_info.txt"
}

resource "null_resource" "dynamodb_provisioners" {
   count      = var.participant_count
   depends_on = [module.workshop-core,local_file.dynamodb_endpoint]

  provisioner "file" {
    source      = "dynamodb_conn_info.txt"
    destination = "/tmp/dynamodb_conn_info.txt"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/dynamodb_conn_info.txt >> ~/.workshop/docker/.env",
      "rm /tmp/dynamodb_conn_info.txt"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}

resource "random_string" "dynamodb_random_string" {
  length = 3
  special = false
  upper = false
  lower = true
  numeric = false
}

data "template_file" "dynamodb_table_name" {
  template = "${var.name}-orders-table-${random_string.dynamodb_random_string.result}"
}

#AWS Credentials

resource "aws_iam_policy" "dynamodb" {
  name = "tf-role-policy-dynamo-${data.template_file.dynamodb_table_name.rendered}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListAndDescribe",
      "Action": [
        "dynamodb:List*",
        "dynamodb:DescribeReservedCapacity*",
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeTimeToLive"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SpecificTable",
      "Action": [
        "dynamodb:BatchGet*",
        "dynamodb:DescribeStream",
        "dynamodb:DescribeTable",
        "dynamodb:Get*",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWrite*",
        "dynamodb:CreateTable",
        "dynamodb:Delete*",
        "dynamodb:Update*",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:dynamodb:*:*:table/${data.template_file.dynamodb_table_name.rendered}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "replicationDynamodb" {
  user       = module.workshop-core.ws_iam_user_name
  policy_arn = aws_iam_policy.dynamodb.arn
}


resource "local_file" "dynamodb_endpoint" {

  content  = <<EOF
DYNAMODB_TABLENAME=${data.template_file.dynamodb_table_name.rendered}
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
      "cat /tmp/dynamodb_conn_info.txt >> .workshop/docker/.env",
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

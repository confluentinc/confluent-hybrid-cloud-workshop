resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  number = false
}

data "template_file" "aws_s3_iam_name" {
  template = "${var.name}-${random_string.random_string.result}"
}

resource "aws_s3_bucket" "bucket" {
  bucket   = "tf-bucket-${data.template_file.aws_s3_iam_name.rendered}"
  acl      = "private"
  region   = var.region
  force_destroy = true

  versioning {
    enabled = false
  }

}

resource "aws_iam_user" "s3" {
  name = "tf-user-${data.template_file.aws_s3_iam_name.rendered}"
  path = "/system/"
}

resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

resource "aws_iam_policy" "s3" {
  name = "tf-role-policy-${data.template_file.aws_s3_iam_name.rendered}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetObject",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket.arn}"
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "replication" {
  user       = aws_iam_user.s3.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "local_file" "s3_bucket_info" {

  content  = <<EOF
AWS_S3_BUCKET_NAME=${aws_s3_bucket.bucket.id}
AWS_S3_REGION=${var.region}
EOF
  filename = "${path.module}/s3_bucket_info.txt"
}

resource "local_file" "aws_credentials" {

  content  = <<EOF
[default]
aws_access_key_id = ${aws_iam_access_key.s3.id}
aws_secret_access_key = ${aws_iam_access_key.s3.secret}
EOF
  filename = "${path.module}/aws_credentials.txt"
}

resource "null_resource" "s3_provisioners" {
   count      = var.participant_count
   depends_on = [
     module.workshop-core,
     local_file.s3_bucket_info,
     local_file.aws_credentials
   ]

  provisioner "file" {
    source      = "s3_bucket_info.txt"
    destination = "/tmp/s3_bucket_info.txt"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }

  provisioner "file" {
    source      = "aws_credentials.txt"
    destination = "/tmp/aws_credentials.txt"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/s3_bucket_info.txt >> ~/.workshop/docker/.env",
      "rm /tmp/s3_bucket_info.txt",
      "docker cp /tmp/aws_credentials.txt kafka-connect-ccloud:/tmp/aws_credentials.txt",
      "docker exec kafka-connect-ccloud mkdir /root/.aws",
      "docker exec kafka-connect-ccloud cp /tmp/aws_credentials.txt /root/.aws/credentials",
      "rm /tmp/aws_credentials.txt"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}
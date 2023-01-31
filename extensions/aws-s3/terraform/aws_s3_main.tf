
resource "random_string" "s3_random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  numeric = false
}

data "template_file" "s3_bucket_name" {
  template = "${var.name}-orders-table-${random_string.s3_random_string.result}"
}

resource "aws_s3_bucket" "bucket" {
  bucket   = "tf-bucket-${data.template_file.s3_bucket_name.rendered}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}


resource "aws_iam_policy" "s3" {
  name = "tf-role-policy-s3-${data.template_file.s3_bucket_name.rendered}"

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
  user       = module.workshop-core.ws_iam_user_name
  policy_arn = aws_iam_policy.s3.arn
}

resource "local_file" "s3_bucket_info" {

  content  = <<EOF
AWS_S3_BUCKET_NAME=${aws_s3_bucket.bucket.id}
AWS_S3_REGION=${var.region}
EOF
  filename = "${path.module}/s3_bucket_info.txt"
}

resource "null_resource" "s3_provisioners" {
   count      = var.participant_count
   depends_on = [
     module.workshop-core,
     local_file.s3_bucket_info
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

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/s3_bucket_info.txt >> .workshop/docker/.env",
      "rm /tmp/s3_bucket_info.txt"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}
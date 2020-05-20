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

resource "local_file" "redshift_cluster_endpoint" {

  content  = <<EOF
RS_JDBC_URL=jdbc:redshift://${aws_redshift_cluster.instance.endpoint}/${var.name}db
RS_USERNAME=${var.rs_username}
RS_PASSWORD=${var.rs_password}
EOF
  filename = "${path.module}/rs_jdbc_url.txt"
}

resource "null_resource" "redshift_provisioners" {
   count      = var.participant_count
   depends_on = [module.workshop-core,local_file.redshift_cluster_endpoint]

  provisioner "file" {
    source      = "rs_jdbc_url.txt"
    destination = "/tmp/rs_jdbc_url.txt"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cp rs_jdbc_url.txt rs_jdbc_url.txt1",
      "cat /tmp/rs_jdbc_url.txt >> ~/.workshop/docker/.env",
      "rm /tmp/rs_jdbc_url.txt"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}
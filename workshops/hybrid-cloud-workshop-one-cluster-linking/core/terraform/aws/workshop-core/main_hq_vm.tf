/*
 Data sources
*/

// Template for hq VM bootstrap script
data "template_file" "bootstrap_vm_hq" {
  template = file("./common/bootstrap_vm.tpl")
  count    = var.cluster_linking
  vars = {
    dc = format("dc%02d", var.participant_count + 1)
    participant_password = var.participant_password
  }
}

// Template for docker bootstrap and startup
data "template_file" "bootstrap_docker_hq" {
  template = file("./common/bootstrap_docker_hq.tpl")
  count    = var.cluster_linking
  vars = {
    dc                      = format("dc%02d", var.participant_count + 1)
    ext_ip                  = aws_instance.instance[count.index].public_ip
    hq_ext_ip               = aws_instance.hq_instance[0].public_ip
    hq_int_ip               = aws_instance.hq_instance[0].private_ip
    ccloud_cluster_endpoint = var.ccloud_bootstrap_servers
    ccloud_api_key          = var.ccloud_api_key
    ccloud_api_secret       = var.ccloud_api_secret
    ccloud_rest_endpoint    = var.ccloud_rest_endpoint
    ccloud_cluster_id       = var.ccloud_cluster_id
    #    ccloud_topics           = var.ccloud_topics
    onprem_topics           = var.onprem_topics
    feedback_form_url       = var.feedback_form_url
    cloud_provider          = "aws"
    cluster_linking          = var.cluster_linking
  }
}

/*
 Resources
*/

resource "aws_instance" "hq_instance" {
  count         = var.cluster_linking
  ami           = var.ami
  instance_type = var.vm_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  subnet_id =  aws_subnet.workshop-public-subnet[0].id

  root_block_device {
    volume_size           = var.vm_disk_size
  }

  user_data  = <<EOF
#! /bin/bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service ssh restart
sudo useradd -m -s /bin/bash ${format("dc%02d", var.participant_count + 1)}
sudo echo "${format("dc%02d", var.participant_count + 1)} ALL = NOPASSWD : ALL" >> /etc/sudoers
sudo usermod -aG sudo ${format("dc%02d", var.participant_count + 1)}
sudo echo "${format("dc%02d", var.participant_count + 1)}:${var.participant_password}" | chpasswd
EOF

  tags = {
    Name = "${var.name}-${ var.participant_count + 1}-hq"
  }
}

/*
 Provisioners
*/
resource "null_resource" "hq_vm_provisioners" {
  depends_on = [aws_instance.hq_instance, local_file.aws_credentials]
  count      = var.cluster_linking

  // Copy bootstrap script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_vm_hq.*.rendered, count.index)
    destination = "/tmp/bootstrap_vm.sh"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.hq_instance[count.index].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_vm.sh",
      "/tmp/bootstrap_vm.sh",
    ]

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.hq_instance[count.index].public_ip
    }
  }
  // Copy docker folder to the VM
  provisioner "file" {
    source      = "../.docker_staging"
    destination = ".workshop/docker"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.hq_instance[count.index].public_ip
    }
  }

  // Copy docker script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_docker_hq.*.rendered, count.index)
    destination = "/tmp/bootstrap_docker_hq.sh"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.hq_instance[count.index].public_ip
    }
  }

  // Execute docker bootstrap script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_docker_hq.sh",
      "/tmp/bootstrap_docker_hq.sh",
    ]

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.hq_instance[count.index].public_ip
    }
  }

  //Adding AWS Credentials for Connect
  provisioner "file" {
    source      = "aws_credentials.txt"
    destination = ".workshop/docker/.aws/credentials"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.hq_instance[count.index].public_ip
    }
  }
}
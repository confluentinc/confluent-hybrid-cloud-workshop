/*
 Data sources
*/

// Template for VM bootstrap script
data "template_file" "bootstrap_vm" {
  template = file("./common/bootstrap_vm.tpl")
  count    = var.participant_count
  vars = {
    dc = format("dc%02d", count.index + 1)
    participant_password = var.participant_password
  }
}

// Template for docker bootstrap and startup
data "template_file" "bootstrap_docker" {
  template = file("./common/bootstrap_docker.tpl")
  count    = var.participant_count
  vars = {
    dc                      = format("dc%02d", count.index + 1)
    ext_ip                  = aws_instance.instance[count.index].public_ip
    ccloud_cluster_endpoint = var.ccloud_bootstrap_servers
    ccloud_api_key          = var.ccloud_api_key
    ccloud_api_secret       = var.ccloud_api_secret
    ccloud_topics           = var.ccloud_topics
    feedback_form_url       = var.feedback_form_url
  }
}

/*
 Resources
*/
resource "aws_instance" "instance" {
  count         = var.participant_count
  ami           = var.ami
  instance_type = var.vm_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data  = <<EOF
#! /bin/bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config 
sudo service ssh restart
sudo useradd -m -s /bin/bash ${format("dc%02d", count.index + 1)}
sudo echo "${format("dc%02d", count.index + 1)} ALL = NOPASSWD : ALL" >> /etc/sudoers
sudo usermod -aG sudo ${format("dc%02d", count.index + 1)}
sudo echo "${format("dc%02d", count.index + 1)}:${var.participant_password}" | chpasswd
EOF

  tags = {
    Name = "${var.name}-${count.index}"
  }
}

resource "aws_security_group" "instance" {

  name = "${var.name}-security-group"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 9021
      to_port     = 9021
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 8088
      to_port     = 8088
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 8089
      to_port     = 8089
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 5539
      to_port     = 5539
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

}

/*
 Provisioners
*/
resource "null_resource" "vm_provisioners" {
  depends_on = [aws_instance.instance]
  count      = var.participant_count

  // Copy bootstrap script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_vm.*.rendered, count.index)
    destination = "/tmp/bootstrap_vm.sh"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.instance[count.index].public_ip
    }
  }

  // Execute bootstrap script on the VM to install tools, Docker & Docker Compose.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_vm.sh",
      "/tmp/bootstrap_vm.sh",
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.instance[count.index].public_ip
    }
  }

  // Copy docker folder to the VM
  provisioner "file" {
    source      = "../.docker_staging"
    destination = ".workshop/docker"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.instance[count.index].public_ip
    }
  }

  // Copy docker script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_docker.*.rendered, count.index)
    destination = "/tmp/bootstrap_docker.sh"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.instance[count.index].public_ip
    }
  }

  // Execute docker bootstrap script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_docker.sh",
      "/tmp/bootstrap_docker.sh",
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.instance[count.index].public_ip
    }
  }
}



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
    hq_ext_ip               = length(aws_instance.hq_instance[*]) > 0 ? aws_instance.hq_instance[0].public_ip : 0
    ccloud_cluster_endpoint = var.ccloud_bootstrap_servers
    ccloud_api_key          = var.ccloud_api_key
    ccloud_api_secret       = var.ccloud_api_secret
    ccloud_rest_endpoint    = var.ccloud_rest_endpoint
    ccloud_cluster_id       = var.ccloud_cluster_id
#    ccloud_topics           = var.ccloud_topics
    onprem_topics           = var.onprem_topics
    feedback_form_url       = var.feedback_form_url
    cloud_provider          = "aws"
    cluster_linking         = var.cluster_linking
    replicator              = var.replicator
  }
}

/*
 Resources
*/


## Create API Key and Secret for the workshop

resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  numeric = false
}

/*data "template_file" "aws_ws_iam_name" {
  template = "${var.name}-${random_string.random_string.result}"
}

resource "aws_iam_user" "ws" {
  name = "tf-user-${data.template_file.aws_ws_iam_name.rendered}"
  path = "/system/"
}

resource "aws_iam_access_key" "ws" {
  user = aws_iam_user.ws.name
}

resource "local_file" "aws_credentials" {

  content  = <<EOF
[default]
aws_access_key_id = ${aws_iam_access_key.ws.id}
aws_secret_access_key = ${aws_iam_access_key.ws.secret}
EOF
  filename = "${path.root}/aws_credentials.txt"
}*/

/*==== The VPC ======*/
resource "aws_vpc" "workshop-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "workshop-ig" {
  vpc_id = aws_vpc.workshop-vpc.id
}

/* Public subnet */
resource "aws_subnet" "workshop-public-subnet" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.workshop-vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_route_table" "workshop-public-route-table" {
  vpc_id = aws_vpc.workshop-vpc.id
}

resource "aws_route" "workshop-public-route" {
  route_table_id         = aws_route_table.workshop-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.workshop-ig.id
}

resource "aws_route_table_association" "workshop-public-route-table-association" {
  count = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.workshop-public-subnet[count.index].id
  route_table_id = aws_route_table.workshop-public-route-table.id
}

resource "aws_instance" "instance" {
  count         = var.participant_count
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
  vpc_id = aws_vpc.workshop-vpc.id

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
      from_port   = 18088
      to_port     = 18088
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 8089
      to_port     = 8089
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  /*ingress {
      from_port   = 5539
      to_port     = 5539
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }*/

  ingress {
      from_port   = 9092
      to_port     = 9092
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 18083
      to_port     = 18083
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 8090
      to_port     = 8090
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
  #depends_on = [aws_instance.instance, local_file.aws_credentials]
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

  //Adding AWS Credentials for Connect
  /*provisioner "file" {
    source      = "aws_credentials.txt"
    destination = ".workshop/docker/.aws/credentials"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = aws_instance.instance[count.index].public_ip
    }
  }*/
}



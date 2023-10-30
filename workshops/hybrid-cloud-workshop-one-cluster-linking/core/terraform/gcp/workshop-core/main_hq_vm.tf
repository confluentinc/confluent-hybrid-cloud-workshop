/*
 Data sources
*/


// Template for VM bootstrap script
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
    hq_ext_ip                  = element(google_compute_address.hq_instance.*.address, count.index)
    ccloud_cluster_endpoint = var.ccloud_bootstrap_servers
    ccloud_api_key          = var.ccloud_api_key
    ccloud_api_secret       = var.ccloud_api_secret
    ccloud_rest_endpoint    = var.ccloud_rest_endpoint
    ccloud_cluster_id       = var.ccloud_cluster_id
    #    ccloud_topics           = var.ccloud_topics
    onprem_topics           = var.onprem_topics
    feedback_form_url       = var.feedback_form_url
    cloud_provider          = "gcp"
    cluster_linking          = var.cluster_linking
  }
}

/*
 Resources
*/
resource "google_compute_address" "hq_instance" {
  count        = var.cluster_linking
  name         = "${var.name}-${var.participant_count}-nic-hq"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "hq_instance" {
  name         = "${var.name}-${count.index}-vm-hq"
  count        = var.cluster_linking
  machine_type = var.vm_type
  zone         = var.region_zone

  boot_disk {
    initialize_params {
      type  = "pd-standard"
      image = "ubuntu-2004-lts"
      size  = var.vm_disk_size
    }
  }

  network_interface {
    network = google_compute_network.workshop-network.self_link

    access_config {
      nat_ip = element(google_compute_address.hq_instance.*.address, count.index)
    }
  }

  metadata_startup_script = <<SCRIPT
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service ssh restart
sudo useradd -m -s /bin/bash ${format("dc%02d", var.participant_count + 1)}
sudo echo "${format("dc%02d", var.participant_count + 1)} ALL = NOPASSWD : ALL" >> /etc/sudoers
sudo usermod -aG sudo ${format("dc%02d", var.participant_count + 1)}
sudo echo "${format("dc%02d", var.participant_count + 1)}:${var.participant_password}" | chpasswd
SCRIPT

  // Copy bootstrap script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_vm_hq.*.rendered, count.index)
    destination = "/tmp/bootstrap_vm.sh"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(google_compute_address.hq_instance.*.address, count.index)
      type     = "ssh"
    }
  }

  // Execute bootstrap script on the VM to install tools, Docker & Docker Compose.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_vm.sh",
      "/tmp/bootstrap_vm.sh",
    ]

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(google_compute_address.hq_instance.*.address, count.index)
      type     = "ssh"
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
      host     = element(google_compute_address.hq_instance.*.address, count.index)
    }
  }

  // Copy docker script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_docker_hq.*.rendered, count.index)
    destination = "/tmp/bootstrap_docker.sh"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(google_compute_address.hq_instance.*.address, count.index)
    }
  }

  // Execute docker bootstrap script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_docker.sh",
      "/tmp/bootstrap_docker.sh",
    ]

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(google_compute_address.hq_instance.*.address, count.index)
    }
  }
}

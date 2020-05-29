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
    ext_ip                  = element(google_compute_address.instance.*.address, count.index)
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

// Network, Firewall, IP's, Virtual machine(s) & file provisioners
resource "google_compute_network" "workshop-network" {
  name = "${var.name}-network"
}

resource "google_compute_firewall" "workshop-firewall" {
  name    = "${var.name}-firewall"
  network = google_compute_network.workshop-network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "9021", "80", "8088", "8089"]
  }
}

resource "google_compute_address" "instance" {
  count        = var.participant_count
  name         = "${var.name}-${count.index}-nic"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "instance" {
  name         = "${var.name}-${count.index}-vm"
  count        = var.participant_count
  machine_type = var.vm_type
  zone         = var.region_zone

  boot_disk {
    initialize_params {
      type  = "pd-standard"
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network = google_compute_network.workshop-network.self_link

    access_config {
      nat_ip = element(google_compute_address.instance.*.address, count.index)
    }
  }

  metadata_startup_script = <<SCRIPT
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config 
sudo service ssh restart
sudo useradd -m -s /bin/bash ${format("dc%02d", count.index + 1)}
sudo echo "${format("dc%02d", count.index + 1)} ALL = NOPASSWD : ALL" >> /etc/sudoers
sudo usermod -aG sudo ${format("dc%02d", count.index + 1)}
sudo echo "${format("dc%02d", count.index + 1)}:${var.participant_password}" | chpasswd
SCRIPT

  // Copy bootstrap script to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_vm.*.rendered, count.index)
    destination = "/tmp/bootstrap_vm.sh"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(google_compute_address.instance.*.address, count.index)
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
      host     = element(google_compute_address.instance.*.address, count.index)
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
      host     = element(google_compute_address.instance.*.address, count.index)
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
      host     = element(google_compute_address.instance.*.address, count.index)
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
      host     = element(google_compute_address.instance.*.address, count.index)
    }
  }
}

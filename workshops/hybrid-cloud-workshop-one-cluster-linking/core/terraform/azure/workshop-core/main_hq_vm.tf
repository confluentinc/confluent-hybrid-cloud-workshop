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
    hq_ext_ip               = element(data.azurerm_public_ip.hq_instance.*.ip_address, count.index)
    ccloud_cluster_endpoint = var.ccloud_bootstrap_servers
    ccloud_api_key          = var.ccloud_api_key
    ccloud_api_secret       = var.ccloud_api_secret
    ccloud_rest_endpoint    = var.ccloud_rest_endpoint
    ccloud_cluster_id       = var.ccloud_cluster_id
    onprem_topics           = var.onprem_topics
    feedback_form_url       = var.feedback_form_url
    cloud_provider          = "azure"
    cluster_linking         = var.cluster_linking
  }
}

/*
 Resources
*/
resource "azurerm_public_ip" "hq_instance" {
  name                = "${var.name}-${var.participant_count}-publicip"
  count               = var.cluster_linking
  resource_group_name = azurerm_resource_group.instance.name
  location            = azurerm_resource_group.instance.location
  allocation_method   = "Dynamic"
  tags                = merge( local.common_tags, local.extra_tags)
}

resource "azurerm_network_interface" "hq_instance" {
  name                = "${var.name}-${var.participant_count}-nic"
  count               = var.cluster_linking
  location            = azurerm_resource_group.instance.location
  resource_group_name = azurerm_resource_group.instance.name
  tags                = merge( local.common_tags, local.extra_tags)

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.instance.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.hq_instance.*.id, count.index)
  }
}

// Workshop virtual machines
resource "azurerm_virtual_machine" "hq_instance" {
  depends_on          = [azurerm_virtual_machine.instance]
  name                  = "${var.name}-${var.participant_count}-vm-hq"
  count                 = var.cluster_linking
  location              = azurerm_resource_group.instance.location
  resource_group_name   = azurerm_resource_group.instance.name
  network_interface_ids = [element(azurerm_network_interface.hq_instance.*.id, count.index)]
  vm_size               = var.vm_type
  tags                  = merge( local.common_tags, local.extra_tags)

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.name}-${var.participant_count + 1}-osdisk-hq"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = var.vm_disk_size
  }

  os_profile {
    computer_name  = "${var.name}-${var.participant_count + 1}-hq"
    admin_username = format("dc%02d", var.participant_count + 1)
    admin_password = var.participant_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


}

/*
 Data sources
*/
data "azurerm_public_ip" "hq_instance" {
  depends_on          = [azurerm_virtual_machine.hq_instance]
  name                = element(azurerm_public_ip.hq_instance.*.name, count.index)
  count               = var.cluster_linking
  resource_group_name = azurerm_resource_group.instance.name
}

resource "null_resource" "hq_vm_provisioners" {
  depends_on = [data.azurerm_public_ip.hq_instance]
  count      = var.cluster_linking

  provisioner "file" {
    content      = element(data.template_file.bootstrap_vm_hq.*.rendered, count.index)
    destination = "/tmp/bootstrap_vm.sh"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(data.azurerm_public_ip.hq_instance.*.ip_address, count.index)
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
      host     = element(data.azurerm_public_ip.hq_instance.*.ip_address, count.index)
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
      host     = element(data.azurerm_public_ip.hq_instance.*.ip_address, count.index)
    }
  }

  // Render the docker bootstrap template to a script and transfer to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_docker_hq.*.rendered, count.index)
    destination = "start_docker_containers.sh"

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(data.azurerm_public_ip.hq_instance.*.ip_address, count.index)
    }
  }

  // Execute docker bootstrap script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x start_docker_containers.sh",
      "./start_docker_containers.sh",
    ]

    connection {
      user     = format("dc%02d", var.participant_count + 1)
      password = var.participant_password
      insecure = true
      host     = element(data.azurerm_public_ip.hq_instance.*.ip_address, count.index)
    }
  }
}


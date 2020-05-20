
locals {
  common_tags = {
    project  = "workshop-framework"
  }
  extra_tags  = {
    workshop-name = "${var.name}"
  }
}

// Template for VM bootstrap script
data "template_file" "bootstrap_vm" {
  template = file("./common/bootstrap_vm.tpl")
  count    = var.participant_count
  vars = {
    dc = format("dc%02d", count.index + 1)
    participant_password = var.participant_password
  }
}

data "template_file" "bootstrap_docker" {
  template = file("./common/bootstrap_docker.tpl")
  count    = var.participant_count
  vars = {
    dc                      = format("dc%02d", count.index + 1)
    ext_ip                  = element(data.azurerm_public_ip.instance.*.ip_address, count.index)
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
resource "azurerm_resource_group" "instance" {
  name     = "${var.name}-resources"
  location = var.location
  tags     = merge( local.common_tags, local.extra_tags)
}

resource "azurerm_virtual_network" "instance" {
  name                = "${var.name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.instance.location
  resource_group_name = azurerm_resource_group.instance.name
  tags                = merge( local.common_tags, local.extra_tags)
}

resource "azurerm_subnet" "instance" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.instance.name
  virtual_network_name = azurerm_virtual_network.instance.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "instance" {
  name                = "${var.name}-${count.index}-publicip"
  count               = var.participant_count
  resource_group_name = azurerm_resource_group.instance.name
  location            = azurerm_resource_group.instance.location
  allocation_method   = "Dynamic"
  tags                = merge( local.common_tags, local.extra_tags)
}

resource "azurerm_network_interface" "instance" {
  name                = "${var.name}-${count.index}-nic"
  count               = var.participant_count
  location            = azurerm_resource_group.instance.location
  resource_group_name = azurerm_resource_group.instance.name
  tags                = merge( local.common_tags, local.extra_tags)

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.instance.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.instance.*.id, count.index)
  }
}

// Workshop virtual machines
resource "azurerm_virtual_machine" "instance" {
  name                  = "${var.name}-${count.index}-vm"
  count                 = var.participant_count
  location              = azurerm_resource_group.instance.location
  resource_group_name   = azurerm_resource_group.instance.name
  network_interface_ids = [element(azurerm_network_interface.instance.*.id, count.index)]
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
    name              = "${var.name}-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.name}-${count.index}"
    admin_username = format("dc%02d", count.index + 1)
    admin_password = var.participant_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  
}

/*
 Data sources
*/
data "azurerm_public_ip" "instance" {
  depends_on          = [azurerm_virtual_machine.instance]
  name                = element(azurerm_public_ip.instance.*.name, count.index)
  count               = var.participant_count
  resource_group_name = azurerm_resource_group.instance.name
}

resource "null_resource" "vm_provisioners" {
  depends_on = [data.azurerm_public_ip.instance]
  count                 = var.participant_count
  provisioner "file" {
    content      = element(data.template_file.bootstrap_vm.*.rendered, count.index)
    destination = "/tmp/bootstrap_vm.sh"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(data.azurerm_public_ip.instance.*.ip_address, count.index)
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
      host     = element(data.azurerm_public_ip.instance.*.ip_address, count.index)
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
      host     = element(data.azurerm_public_ip.instance.*.ip_address, count.index)
    }
  }

  // Render the docker bootstrap template to a script and transfer to the VM
  provisioner "file" {
    content     = element(data.template_file.bootstrap_docker.*.rendered, count.index)
    destination = "start_docker_containers.sh"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(data.azurerm_public_ip.instance.*.ip_address, count.index)
    }
  }

  // Execute docker bootstrap script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x start_docker_containers.sh",
      "./start_docker_containers.sh",
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(data.azurerm_public_ip.instance.*.ip_address, count.index)
    }
  }
}


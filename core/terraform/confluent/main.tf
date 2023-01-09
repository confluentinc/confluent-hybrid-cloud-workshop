terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
    }
  }
}
provider "confluent" {
  cloud_api_key    = var.ccloud_api_key
  cloud_api_secret = var.ccloud_api_secret
}

resource "confluent_environment" "environment" {
  display_name = "${var.name}"
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "basic" {
  display_name = "${var.name}"
  availability = "SINGLE_ZONE"
  cloud        = var.cloud
  region       = var.region
  basic {}
  environment {
    id = confluent_environment.environment.id
  }
}

resource "confluent_service_account" "app-manager" {
  display_name = "${var.name}-app-manager"
  description  = "Service account to manage 'demo' Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "${var.name}-app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.environment.id
    }
  }
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

module "cloud-services" {
  source                   = "./modules/cloud"
  name                     = var.name
  participant_count        = var.participant_count
  participant_password     = var.participant_password
  region                   = var.region
  profile                  = var.profile
  vm_type                  = var.vm_type
  vm_disk_size             = var.vm_disk_size
  ami                      = var.ami
  ccloud_bootstrap_servers = confluent_kafka_cluster.basic.bootstrap_endpoint
  ccloud_api_key           = confluent_api_key.app-manager-kafka-api-key.id
  ccloud_api_secret        = confluent_api_key.app-manager-kafka-api-key.secret
  ccloud_topics            = var.ccloud_topics
  onprem_topics            = var.onprem_topics
  feedback_form_url        = var.feedback_form_url
  owner_email              = var.owner_email
}



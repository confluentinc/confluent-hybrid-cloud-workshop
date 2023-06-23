terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      #version = "1.24.0"
    }
  }
}

data "confluent_schema_registry_region" "sr_region" {
  cloud   = upper(var.cloud_provider)
  region  = var.ccloud_sr_region
  package = var.ccloud_package_sg
}

provider "confluent" {
  # Configuration options
  cloud_api_key    = var.ccloud_api_key
  cloud_api_secret = var.ccloud_api_secret

}

resource "confluent_environment" "hybrid-workshop" {
  display_name = "${var.name}-${var.ccloud_env_name}"

}

resource "confluent_kafka_cluster" "hybrid-cluster" {
  display_name = "${var.name}-${var.ccloud_cluster_name}"
  availability = var.ccloud_cluster_availability_type
  cloud        = upper(var.cloud_provider)
  region       = var.region
  #basic {}
  dedicated {
    cku = 1
  }

  environment {
    id = confluent_environment.hybrid-workshop.id
  }

}

resource "confluent_schema_registry_cluster" "essentials" {
  package = data.confluent_schema_registry_region.sr_region.package

  environment {
    id = confluent_environment.hybrid-workshop.id
  }

  region {
    id = data.confluent_schema_registry_region.sr_region.id
  }
}

resource "confluent_service_account" "hybrid-manager" {
  display_name = "${var.name}-hybrid-manager"
  description  = "Service Account for hybrid workshop"
}

resource "confluent_role_binding" "hybrid-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.hybrid-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.hybrid-cluster.rbac_crn
}

resource "confluent_api_key" "hybrid-manager-kafka-api-key" {
  display_name = "${var.name}-hybrid-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'sa-hybrid-service_account' service account"
  owner {
    id          = confluent_service_account.hybrid-manager.id
    api_version = confluent_service_account.hybrid-manager.api_version
    kind        = confluent_service_account.hybrid-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.hybrid-cluster.id
    api_version = confluent_kafka_cluster.hybrid-cluster.api_version
    kind        = confluent_kafka_cluster.hybrid-cluster.kind

    environment {
      id = confluent_environment.hybrid-workshop.id

    }
  }
  depends_on = [
    confluent_role_binding.hybrid-manager-kafka-cluster-admin
  ]
}


resource "confluent_kafka_topic" "topic" {
  count           = length(local.product)

  kafka_cluster {
    id = confluent_kafka_cluster.hybrid-cluster.id
  }
  topic_name = format("dc%02d_%s%s",element(local.product, count.index)[0],element(local.product, count.index)[1],"-replicator")
  partitions_count   = 1
  rest_endpoint      = confluent_kafka_cluster.hybrid-cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.hybrid-manager-kafka-api-key.id
    secret = confluent_api_key.hybrid-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "hybrid-manager-write-on-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.hybrid-cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dc_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.hybrid-manager.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.hybrid-cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.hybrid-manager-kafka-api-key.id
    secret = confluent_api_key.hybrid-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "hybrid-manager-delete-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.hybrid-cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dc_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.hybrid-manager.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.hybrid-cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.hybrid-manager-kafka-api-key.id
    secret = confluent_api_key.hybrid-manager-kafka-api-key.secret
  }
}
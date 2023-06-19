output "topics" {
  value =local.product
}

output "boostrap" {
  value =confluent_kafka_cluster.hybrid-cluster.bootstrap_endpoint
}

output "cluster_api_key" {
  value = confluent_api_key.hybrid-manager-kafka-api-key.id
}

output "cluster_api_secret" {
  value = confluent_api_key.hybrid-manager-kafka-api-key.secret
}

output "cluster_id" {
  value = confluent_kafka_cluster.hybrid-cluster.id
}

output "rest_endpoint" {
  value = confluent_kafka_cluster.hybrid-cluster.rest_endpoint
}
output "mongodbatlas_mongo_uri" {
  value = data.mongodbatlas_cluster.confluent.mongo_uri
}
output "mongodbatlas_mongo_uri_with_options" {
  value = data.mongodbatlas_cluster.confluent.mongo_uri_with_options
}
output "mongodbatlas_srv_address" {
  value = format("mongodb+srv://%s:%s@%s",var.mongodbatlas_dbuser_username,var.mongodbatlas_dbuser_password,replace(data.mongodbatlas_cluster.confluent.srv_address, "mongodb+srv://", ""))
}


 
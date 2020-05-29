# Configure the MongoDB Atlas Provider
provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = var.mongodbatlas_private_key
}

locals {
  mongodbatlas_srv_address = format("mongodb+srv://%s:%s@%s",var.mongodbatlas_dbuser_username,var.mongodbatlas_dbuser_password,replace(data.mongodbatlas_cluster.confluent.srv_address, "mongodb+srv://", ""))
}

resource "mongodbatlas_cluster" "confluent" {
  project_id   = var.mongodbatlas_project_id
  name         = "ConfluentWS"
  num_shards   = 1

  replication_factor           = 3
  backup_enabled               = false
  auto_scaling_disk_gb_enabled = false
  mongo_db_major_version       = var.mongodbatlas_mongo_db_major_version

  //Provider Settings "block"
  provider_name               = var.mongodbatlas_provider_name
  disk_size_gb                = var.mongodbatlas_disk_size_gb
  provider_instance_size_name = var.mongodbatlas_provider_instance_size_name
  provider_region_name        = var.mongodbatlas_provider_region_name
}

data "mongodbatlas_cluster" "confluent" {
    depends_on   = [mongodbatlas_cluster.confluent]
    project_id = mongodbatlas_cluster.confluent.project_id
    name       = mongodbatlas_cluster.confluent.name
}

# There is no Atlas API to create a DB, but the user need access to it. So here we create the rule for the db "demo". The DB will be automatically created as soon as the connect tries to push data to it. Still, this rule need to exist beforehand
resource "mongodbatlas_database_user" "confluent" {
    username      = var.mongodbatlas_dbuser_username
    password      = var.mongodbatlas_dbuser_password
    project_id    = mongodbatlas_cluster.confluent.project_id
    auth_database_name = "admin"

    roles {
        role_name     = "readWrite"
        database_name = "demo"
    }
}

resource "mongodbatlas_project_ip_whitelist" "confluent" {
    depends_on = [module.workshop-core]
    count      = var.participant_count
    project_id = mongodbatlas_cluster.confluent.project_id
    ip_address = element(module.workshop-core.external_ip_addresses, count.index)
    comment    = "ip address for tf acc testing"
}

resource "null_resource" "vm_provisioners_atlas" {
   depends_on = [module.workshop-core]
   count      = var.participant_count

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "echo 'MONGODBATLAS_SRV_ADDRESS=${local.mongodbatlas_srv_address}' >> ~/.workshop/docker/.env",
      "echo 'MONGODBATLAS_MONGO_URI=${data.mongodbatlas_cluster.confluent.mongo_uri}' >> ~/.workshop/docker/.env"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}


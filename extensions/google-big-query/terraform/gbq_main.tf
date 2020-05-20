
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "${var.name}_dataset"
  friendly_name               = "Workshop Dataset"
  description                 = "Workshop Dataset"
  project                     = var.gbq_project
  location                    = var.gbq_location
  delete_contents_on_destroy  = true

  access {
    role          = "roles/bigquery.dataEditor"
    user_by_email = google_service_account.gbq_service_account.email
  }

  access {
    role          = "roles/bigquery.dataEditor"
    special_group = "allAuthenticatedUsers"
  }
}

resource "google_service_account" "gbq_service_account" {
  account_id   = "${var.name}-gbq"
  display_name = "Workshop Big Query Service Account"
}
resource "google_service_account_key" "gbq_key" {
  service_account_id = google_service_account.gbq_service_account.id
}
resource "local_file" "gbq_creds_json" {
  content  = base64decode(google_service_account_key.gbq_key.private_key)
  filename = "${path.module}/gbq_creds.json"
}

resource "null_resource" "gbq_provisioners" {
   count      = var.participant_count
   depends_on = [module.workshop-core]

  provisioner "file" {
    source      = "gbq_creds.json"
    destination = "/tmp/gbq_creds.json"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 180",
      "echo 'GBQ_CREDENTIALS_PATH=/tmp/gbq_creds.json' >> ~/.workshop/docker/.env",
      "echo 'GBQ_DATASET=${var.name}_dataset' >> ~/.workshop/docker/.env",
      "echo 'GBQ_PROJECT=${var.gbq_project}' >> ~/.workshop/docker/.env",
      "docker cp /tmp/gbq_creds.json kafka-connect-ccloud:/tmp",
      "rm /tmp/gbq_creds.json"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}



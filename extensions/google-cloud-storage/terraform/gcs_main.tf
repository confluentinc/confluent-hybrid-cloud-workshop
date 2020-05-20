resource "google_storage_bucket" "instance" {
  name          = "${var.name}-gcssink-bucket"
  location      = var.gcs_region
  project       = var.gcs_project
  force_destroy = "true"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_service_account" "myaccount" {
  account_id   = "${var.name}-gcs"
  display_name = "Workshop Storage Account"
}
resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.myaccount.id
}
resource "local_file" "myaccountjson" {
  content  = base64decode(google_service_account_key.mykey.private_key)
  filename = "${path.module}/gcs_creds.json"
}

resource "google_storage_bucket_iam_binding" "legacyBucketReaderBinding" {
  bucket = "${var.name}-gcssink-bucket"
  role   = "roles/storage.legacyBucketReader"
  depends_on = [module.workshop-core]

  members = [
    "serviceAccount:${google_service_account.myaccount.email}"
  ]
}
 
resource "google_storage_bucket_iam_binding" "legacyBucketWriterBinding" {
  bucket     = "${var.name}-gcssink-bucket"
  role       = "roles/storage.legacyBucketWriter"
  depends_on = [module.workshop-core]

  members = [
    "serviceAccount:${google_service_account.myaccount.email}"
  ]
}

resource "null_resource" "vm_provisioners" {
   count      = var.participant_count
   depends_on = [module.workshop-core]

  provisioner "file" {
    source      = "gcs_creds.json"
    destination = "/tmp/gcs_creds.json"

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "echo 'GCS_BUCKET_NAME=${var.name}-gcssink-bucket' >> ~/.workshop/docker/.env",
      "echo 'GCS_CREDENTIALS_PATH=/tmp/gcs_creds.json' >> ~/.workshop/docker/.env",
      "docker cp /tmp/gcs_creds.json kafka-connect-ccloud:/tmp",
      "rm /tmp/gcs_creds.json"
    ]

    connection {
      user     = format("dc%02d", count.index + 1)
      password = var.participant_password
      insecure = true
      host     = element(module.workshop-core.external_ip_addresses, count.index)
    }
  }
}



output "gcp_storage_self_link" {
  value = google_storage_bucket.instance.*.self_link
}

output "gcp_storage_url" {
  value = google_storage_bucket.instance.*.url
}

output "external_ip_addresses" {
  value = google_compute_address.instance.*.address
}

output "google_compute_instance" {
  value = google_compute_instance.instance
}

resource "google_compute_firewall" "default" {
  name      = "allow-ssh"
  network   = google_compute_network.default.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.app}-ex-ilb-forwarding-rule"
  target                = google_compute_target_http_proxy.default.self_link
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.app}-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_url_map" "default" {
  name            = "${var.app}-lb"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_http_health_check" "default" {
  name         = "${var.app}-ex-lb-hc"
  request_path = "/"
  port         = 80
}

resource "google_compute_backend_service" "default" {
  name                  = "${var.app}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group           = google_compute_instance_group_manager.mig.instance_group
    capacity_scaler = 1
    balancing_mode  = "UTILIZATION"
  }
  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_forwarding_rule" "default" {
  name                  = "${var.nlb}-frontend"
  project               = var.project_id
  backend_service       = google_compute_region_backend_service.default.self_link
  region                = var.region
  ip_protocol           = var.protocol
  load_balancing_scheme = var.load_balancing_scheme
  ports                 = var.ports
  all_ports             = var.all_ports
  allow_global_access   = var.allow_global_access
  network               = var.load_balancing_scheme == "EXTERNAL" ? null : var.network
  subnetwork            = var.load_balancing_scheme == "EXTERNAL" ? null : var.subnetwork
  ip_address            = var.load_balancing_scheme == "EXTERNAL" ? null : google_compute_address.ip.id
}

resource "google_compute_region_backend_service" "default" {
  name                            = "${var.nlb}-lb"
  project                         = var.project_id
  region                          = var.region
  protocol                        = var.protocol
  network                         = var.load_balancing_scheme == "EXTERNAL" ? null : var.network
  load_balancing_scheme           = var.load_balancing_scheme
  health_checks                   = var.hc
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  timeout_sec                     = 300
  backend {
    group          = var.mig
    balancing_mode = "CONNECTION"
  }
  log_config {
    enable      = true
    sample_rate = 1
  }
  #circuit_breakers {
  #  max_connections = 15000
  #  max_requests = 100000
  #}  
}

resource "google_compute_address" "ip" {
  name         = "${var.nlb}-ip"
  project      = var.project_id
  region       = var.region
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
  address      = var.lb_ip
}
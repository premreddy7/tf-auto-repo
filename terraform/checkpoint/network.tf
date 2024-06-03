resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
}

resource "google_compute_network" "vpc_external" {
  name                    = "vpc-external"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true
  depends_on = [google_project_service.compute_api  ]
}

resource "google_compute_subnetwork" "sb_external_1" {
  name          = "sb-external-1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-south1"
  network       = google_compute_network.vpc_external.id
}

resource "google_compute_network" "vpc_internal" {
  name                    = "vpc-internal"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true
    depends_on = [google_project_service.compute_api  ]
}

resource "google_compute_subnetwork" "sb_internal_1" {
  name          = "sb-internal-1"
  ip_cidr_range = "10.1.0.0/24"
  region        = "asia-south1"
  network       = google_compute_network.vpc_internal.id
}

resource "google_compute_network" "vpc_mgn" {
  name                    = "vpc-mgn"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true
    depends_on = [google_project_service.compute_api  ]
}

resource "google_compute_subnetwork" "sb_mgn" {
  name          = "sb-mgn"
  ip_cidr_range = "10.2.0.0/24"
  region        = "asia-south1"
  network       = google_compute_network.vpc_mgn.id
}

resource "google_compute_network_peering" "peering_internal_mgn" {
  name         = "peering-internal-mgn"
  network      = google_compute_network.vpc_internal.self_link
  peer_network = google_compute_network.vpc_mgn.self_link

}

resource "google_compute_network_peering" "peering_mgn_internal" {
  name         = "peering-mgn-internal"
  network      = google_compute_network.vpc_mgn.self_link
  peer_network = google_compute_network.vpc_internal.self_link
}

# MGN VPC
resource "google_compute_route" "rdp_route" {
  name           = "rdp-route"
  network        = google_compute_network.vpc_mgn.self_link
  dest_range     = "0.0.0.0/0"
  priority       = 100
  next_hop_gateway = "default-internet-gateway"
  tags           = ["rdp", "checkpoint-management"]
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.vpc_mgn.self_link
  region  = "asia-south1"
}

resource "google_compute_router_nat" "mgn_nat_gateway" {
  name                               = "nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = "asia-south1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  timeouts {
    create = "20m"
    update = "20m"
  }
}


# Internal VPC
resource "google_compute_route" "internal_vpc_route" {
  name           = "all-int-default-route"
  network        = google_compute_network.vpc_internal.self_link
  dest_range     = "0.0.0.0/0"
  priority       = 100
  next_hop_ilb      = module.chk-int-nlb.nlb_id
}

# External VPC
resource "google_compute_route" "ext_vpc_route" {
  name           = "all-ext-default-route"
  network        = google_compute_network.vpc_external.self_link
  dest_range     = "0.0.0.0/0"
  priority       = 100
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_router" "ext_vpc_router" {
  name    = "ext-vpc-nat-router"
  network = google_compute_network.vpc_external.self_link
  region  = "asia-south1"
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "nat-ext-vpc-gateway"
  router                             = google_compute_router.ext_vpc_router.name
  region                             = "asia-south1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  timeouts {
    create = "20m"
    update = "20m"
  }
}


resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-ssh-rdp"
  network = google_compute_network.vpc_mgn.self_link

  allow {
    protocol = "tcp"
    ports    = ["3389", "22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rdp", "checkpoint-management"]

  description = "Allow RDP, ssh traffic from any source"
}

resource "google_compute_firewall" "checkpoint_fw" {
  name    = "checkpoint-rules-0"
  network = google_compute_network.vpc_mgn.self_link

  allow {
    protocol = "tcp"
    ports    =  ["18184", "18187", "256", "257", "443", "3389", "22", "18191", "19009"]
  }

  source_ranges = ["10.1.0.0/24", "10.2.0.0/24"]
}

resource "google_compute_firewall" "checkpoint_gw_fw" {
  name    = "checkpoint-rules-gw-0"
  network = google_compute_network.vpc_internal.self_link

  allow {
    protocol = "tcp"
    ports    =  ["161", "162", "256", "257", "443", "18183", "18184", "18186", "18187", "18191", "18192", "18193", "18194", "18208", "18209", "18210", "18211"]
  }

  source_ranges = ["10.2.0.0/24"]
}


resource "google_compute_firewall" "checkpoint_gw_fw1" {
  name    = "checkpoint-rules-gw-1"
  network = google_compute_network.vpc_internal.self_link

  allow {
    protocol = "tcp"
    ports    =  ["443", "8117"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
}

resource "google_compute_firewall" "checkpoint_gw_fw2" {
  name    = "checkpoint-rules-gw-2"
  network = google_compute_network.vpc_external.self_link

  allow {
    protocol = "tcp"
    ports    =  ["443", "8117"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
}
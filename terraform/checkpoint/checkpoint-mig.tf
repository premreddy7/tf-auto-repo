module "chk-mig" {
  source                      = "../modules/cloudguard/"
  project                     = local.project
  prefix                      = var.mig_prefix
  license                     = var.license
  image_name                  = var.mig_image_name
  port_details                = var.port_details
  management_name             = var.management_name
  management_nic              = "Private IP (eth1)"
  configuration_template_name = var.configuration_template_name
  admin_SSH_key               = var.admin_SSH_key
  admin_shell                 = "/bin/bash"
  allow_upload_download       = var.allow_upload_download
  region                      = var.region
  external_network_name       = var.external_network_name
  external_subnetwork_name    = var.external_subnetwork_name
  internal_network_name       = var.internal_network_name
  internal_subnetwork_name    = var.internal_subnetwork_name
  machine_type                = var.mig_machine_type
  cpu_usage                   = var.cpu_usage
  instances_min_grop_size     = var.instances_min_grop_size
  instances_max_grop_size     = var.instances_max_grop_size
  disk_type                   = var.disk_type
  disk_size                   = var.disk_size
  enable_monitoring           = var.enable_monitoring
  depends_on = [ google_compute_network.vpc_external, google_compute_network.vpc_internal ]
}  


resource "google_compute_health_check" "default" {
  name                = "${var.prefix}-hc"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  tcp_health_check {
    port = "8117"
  }
}

module "chk-int-nlb" {
  source                = "../modules/nlb_internal/"
  nlb                   = "${var.prefix}-tcp-int"
  mig                   = module.chk-mig.instance_group
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  network               = google_compute_network.vpc_internal.name
  subnetwork            = google_compute_subnetwork.sb_internal_1.name
  hc                    = [google_compute_health_check.default.id]
  lb_ip                 = var.internal_lb_ip
}
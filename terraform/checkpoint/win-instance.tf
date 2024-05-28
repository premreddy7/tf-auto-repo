module "chk-win" {
  source              = "../modules/mng-instance/"
  instance_name       = var.instance_name
  instance            = var.instance
  domain              = var.app_domain
  network             = "${google_compute_network.vpc_mgn.name}"
  subnetwork          = "${google_compute_subnetwork.sb_mgn.name}"
  zone                = var.gcp_zone
  instance_type       = var.windows_instance_type
  image               = var.image
  disk_size_gb        = var.disk_size_gb
  disk_type           = var.disk_type_condition
  tags                = var.tags
  labels              = var.labels
  vm_ipaddress        = var.vm_ipaddress
}
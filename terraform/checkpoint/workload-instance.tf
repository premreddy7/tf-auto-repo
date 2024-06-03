module "compute-instance" {
  source              = "../modules/mng-instance/"
  instance_name       = "linux-instance"
  instance            = "linux"
  domain              = ""
  network             = "${google_compute_network.vpc_internal.name}"
  subnetwork          = "${google_compute_subnetwork.sb_internal_1.name}"
  zone                = "asia-south1-a"
  instance_type       = "n2-standard-4"
  image               = "ubuntu-os-cloud/ubuntu-2004-focal-v20240519"
  disk_size_gb        = "100"
  disk_type           = "pd-balanced"
  tags                = ["linux"]
  labels              = {}
  vm_ipaddress        = "10.1.0.10"
}
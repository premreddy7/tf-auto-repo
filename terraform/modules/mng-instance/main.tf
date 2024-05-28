# Create VM
resource "google_compute_instance" "vm_instance" {
  name                      = var.instance_name
  machine_type              = var.instance_type
  zone                      = var.zone
  hostname                  = var.instance != "windows" ? "" : "${var.instance_name}.${var.domain}"
  tags                      = var.tags
  labels                    = var.labels
  metadata_startup_script   = var.startup_script
  allow_stopping_for_update = var.allow_stopping_for_update
  boot_disk {
    auto_delete = var.auto_delete
    initialize_params {
      size  = var.disk_size_gb
      type  = var.disk_type
      image = var.image != "" ? var.image : "windows-cloud/windows-2019"
    }
  }

  dynamic "attached_disk" {
    for_each = var.disks != "" ? var.disks : {}
    content {
      source      = google_compute_disk.default[attached_disk.key].id
      device_name = attached_disk.value["device_name"]
    }
  }
  service_account {
    email  = var.service_account == "" ? "" : var.service_account
    scopes = var.scopes
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    network_ip = var.vm_ipaddress == "" ? "" : var.vm_ipaddress
    access_config {
      // Ephemeral public IP
    }
  }
  metadata = {
    block-project-ssh-keys = "${var.block-project-ssh-keys}"
    serial-port-enable     = "${var.serial-port-enable}"
    ssh-keys               = var.ssh-keys == "" ? null : file(var.ssh-keys)
    enable-oslogin         = var.enable_oslogin

  }
  scheduling {
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.preemptible
  }
  deletion_protection = var.deletion_protection
}


resource "google_compute_disk" "default" {
  for_each = var.disks
  name     = "${var.instance_name}-disk-${each.key}"
  type     = each.value.type
  zone = var.zone
  size = each.value.size
}

#resource "google_compute_attached_disk" "default" {
#  for_each = var.disks
#  disk     = google_compute_disk.default[each.key].id
#  instance = google_compute_instance.vm_instance.id
#}
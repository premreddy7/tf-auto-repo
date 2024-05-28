locals {
  license_allowed_values = [
    "BYOL",
  "PAYG"]
  // will fail if [var.license] is invalid:
  validate_license = index(local.license_allowed_values, upper(var.license))

  installation_type_allowed_values = [
    "Gateway only",
    "Management only",
    "Standalone"
  ]
  // Will fail if the installation type is none of the above
  validate_installation_type = index(local.installation_type_allowed_values, var.installationType)

  regex_validate_mgmt_image_name   = "check-point-r8[0-1][1-4]0-(byol|payg)-[0-9]{3}-([0-9]{3}|[a-z]+)-v[0-9]{8,}"
  regex_validate_single_image_name = "check-point-r8[0-1][1-4]0-gw-(byol|payg)-single-[0-9]{3}-([0-9]{3}|[a-z]+)-v[0-9]{8,}"
  // will fail if the image name is not in the right syntax
  validate_image_name       = var.installationType != "Gateway only" && length(regexall(local.regex_validate_mgmt_image_name, var.image_name)) > 0 ? 0 : (var.installationType == "Gateway only" && length(regexall(local.regex_validate_single_image_name, var.image_name)) > 0 ? 0 : index(split("-", var.image_name), "INVALID IMAGE NAME"))
  regex_valid_admin_SSH_key = "^(^$|ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3})"
  // Will fail if var.admin_SSH_key is invalid
  regex_admin_SSH_key = regex(local.regex_valid_admin_SSH_key, var.admin_SSH_key) == var.admin_SSH_key ? 0 : "Please enter a valid SSH public key or leave empty"
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
  "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)
  disk_type_allowed_values = [
    "SSD Persistent Disk",
    "Balanced Persistent Disk",
  "Standard Persistent Disk"]
  // Will fail if var.disk_type is invalid
  validate_disk_type          = index(local.disk_type_allowed_values, var.diskType)
  adminPasswordSourceMetadata = var.generatePassword ? random_string.generated_password.result : ""
  disk_type_condition         = var.diskType == "SSD Persistent Disk" ? "pd-ssd" : var.diskType == "Balanced Persistent Disk" ? "pd-balanced" : var.diskType == "Standard Persistent Disk" ? "pd-standard" : ""
  admin_SSH_key_condition     = var.admin_SSH_key != "" ? true : false
  ICMP_traffic_condition      = length(var.network_icmpSourceRanges) == 0 ? 0 : 1
  TCP_traffic_condition       = length(var.network_tcpSourceRanges) == 0 ? 0 : 1
  UDP_traffic_condition       = length(var.network_udpSourceRanges) == 0 ? 0 : 1
  SCTP_traffic_condition      = length(var.network_sctpSourceRanges) == 0 ? 0 : 1
  ESP_traffic_condition       = length(var.network_espSourceRanges) == 0 ? 0 : 1
  project                     = "checkpoint-prj"
}


resource "google_service_account" "chk_sa" {
  account_id   = var.checkpoint-sa
  display_name = var.checkpoint-sa
  description  = "SA to Check Point Security Management Server to monitor the creation and state of the autoscaling Managed Instance Group."
}

resource "google_project_iam_member" "chk_permissions" {
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.chk_sa.email}"
  project = local.project
}





resource "random_string" "random_string" {
  length  = 5
  special = false
  upper   = false
  keepers = {}
}
data "google_compute_network" "external_network" {
  name = google_compute_network.vpc_mgn.name
}
resource "random_string" "random_sic_key" {
  length  = 12
  special = false
}

resource "google_compute_firewall" "ICMP_firewall_rules" {
  count   = local.ICMP_traffic_condition
  name    = "${var.prefix}-icmp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "icmp"
  }
  source_ranges = var.network_icmpSourceRanges
  target_tags = [
  "checkpoint-${replace(replace(lower(var.installationType), " ", "-"), "(standalone)", "standalone")}"]
}
resource "google_compute_firewall" "TCP_firewall_rules" {
  count   = local.TCP_traffic_condition
  name    = "${var.prefix}-tcp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "tcp"
  }
  source_ranges = var.network_tcpSourceRanges
  target_tags = [
  "checkpoint-${replace(replace(lower(var.installationType), " ", "-"), "(standalone)", "standalone")}"]
}
resource "google_compute_firewall" "UDP_firewall_rules" {
  count   = local.UDP_traffic_condition
  name    = "${var.prefix}-udp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "udp"
  }
  source_ranges = var.network_udpSourceRanges
  target_tags = [
  "checkpoint-${replace(replace(lower(var.installationType), " ", "-"), "(standalone)", "standalone")}"]
}
resource "random_string" "generated_password" {
  length  = 12
  special = false
}
resource "google_compute_firewall" "SCTP_firewall_rules" {
  count   = local.SCTP_traffic_condition
  name    = "${var.prefix}-sctp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "sctp"
  }
  source_ranges = var.network_sctpSourceRanges
  target_tags = [
  "checkpoint-${replace(replace(lower(var.installationType), " ", "-"), "(standalone)", "standalone")}"]
}
resource "google_compute_firewall" "ESP_firewall_rules" {
  count   = local.ESP_traffic_condition
  name    = "${var.prefix}-esp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "esp"
  }
  source_ranges = var.network_espSourceRanges
  target_tags = [
  "checkpoint-${replace(replace(lower(var.installationType), " ", "-"), "(standalone)", "standalone")}"]
}

resource "google_compute_instance" "gateway" {
  name                = var.prefix
  description         = "Check Point Security ${replace(var.installationType, "(Standalone)", "--") == var.installationType ? split(" ", var.installationType)[0] : " Gateway and Management"}"
  zone                = var.zone
  labels              = { env = "common", application = "checkpoint-management" }
  tags                = ["checkpoint-management", "${var.prefix}${random_string.random_string.result}", "egress-internet", var.region]
  machine_type        = var.machine_type
  can_ip_forward      = var.installationType == "Management only" ? false : true
  deletion_protection = true
  boot_disk {
    auto_delete = true
    device_name = "chkp-single-boot-${random_string.random_string.result}"
    initialize_params {
      size  = var.bootDiskSizeGb
      type  = local.disk_type_condition
      image = "checkpoint-public/${var.image_name}"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_mgn.name
    subnetwork = google_compute_subnetwork.sb_mgn.name
    network_ip = var.chk_vm_ipaddress == "" ? null : var.chk_vm_ipaddress
    dynamic "access_config" {
      for_each = var.externalIP == "None" ? [] : [1]
      content {
        nat_ip = var.externalIP == "static" ? google_compute_address.static.address : null
      }
    }

  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 1 ? [
    1] : []
    content {
      network    = var.internal_network1_network[0]
      subnetwork = var.internal_network1_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 2 ? [
    1] : []
    content {
      network    = var.internal_network2_network[0]
      subnetwork = var.internal_network2_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 3 ? [
    1] : []
    content {
      network    = var.internal_network3_network[0]
      subnetwork = var.internal_network3_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 4 ? [
    1] : []
    content {
      network    = var.internal_network4_network[0]
      subnetwork = var.internal_network4_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 5 ? [
    1] : []
    content {
      network    = var.internal_network5_network[0]
      subnetwork = var.internal_network5_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs == 6 ? [
    1] : []
    content {
      network    = var.internal_network6_network[0]
      subnetwork = var.internal_network6_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs == 7 ? [
    1] : []
    content {
      network    = var.internal_network7_network[0]
      subnetwork = var.internal_network7_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs == 8 ? [
    1] : []
    content {
      network    = var.internal_network8_network[0]
      subnetwork = var.internal_network8_subnetwork[0]
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloudruntimeconfig",
    "https://www.googleapis.com/auth/monitoring.write"]
  }

  metadata = local.admin_SSH_key_condition ? {
    instanceSSHKey              = var.admin_SSH_key
    adminPasswordSourceMetadata = var.generatePassword ? random_string.generated_password.result : ""
  } : { adminPasswordSourceMetadata = var.generatePassword ? random_string.generated_password.result : "" }

  metadata_startup_script = templatefile("startup-script.sh", {
    // script's arguments
    generatePassword               = var.generatePassword
    config_url                     = "https://runtimeconfig.googleapis.com/v1beta1/projects/${local.project}/configs/-config"
    config_path                    = "projects/${local.project}/configs/-config"
    sicKey                         = ""
    allowUploadDownload            = var.allowUploadDownload
    templateName                   = "single_tf"
    templateVersion                = "20211128"
    templateType                   = "terraform"
    hasInternet                    = "true"
    enableMonitoring               = var.enableMonitoring
    shell                          = var.admin_shell
    installationType               = var.installationType
    computed_sic_key               = var.sicKey
    managementGUIClientNetwork     = var.managementGUIClientNetwork
    installSecurityManagement      = true
    primary_cluster_address_name   = ""
    secondary_cluster_address_name = ""
    subnet_router_meta_path        = ""
    mgmtNIC                        = var.management_nic
    managementNetwork              = ""
    numAdditionalNICs              = ""
  })
}
resource "google_compute_address" "static" {
  name   = var.prefix
  region = var.region
}
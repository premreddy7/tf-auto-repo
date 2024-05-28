output "vpc_external_id" {
  value = google_compute_network.vpc_external.id
}

output "vpc_internal_id" {
  value = google_compute_network.vpc_internal.id
}

output "vpc_mgn_id" {
  value = google_compute_network.vpc_mgn.id
}

output "sb_external_1_id" {
  value = google_compute_subnetwork.sb_external_1.id
}

output "sb_internal_1_id" {
  value = google_compute_subnetwork.sb_internal_1.id
}

output "sb_mgn_id" {
  value = google_compute_subnetwork.sb_mgn.id
}

output "peering_internal_mgn_id" {
  value = google_compute_network_peering.peering_internal_mgn.id
}

output "peering_mgn_internal_id" {
  value = google_compute_network_peering.peering_mgn_internal.id
}

output "vm-name" {
  value = module.chk-win.vm-name
}
output "vm-internal-ip" {
  value = module.chk-win.vm-internal-ip
}

## CheckPoint MGN

output "SIC_key" {
  value = random_string.random_sic_key.result
}
output "ICMP_firewall_rules_name" {
  value = google_compute_firewall.ICMP_firewall_rules[*].name
}
output "TCP_firewall_rules_name" {
  value = google_compute_firewall.TCP_firewall_rules[*].name
}
output "UDP_firewall_rules_name" {
  value = google_compute_firewall.UDP_firewall_rules[*].name
}
output "SCTP_firewall_rules_name" {
  value = google_compute_firewall.SCTP_firewall_rules[*].name
}
output "ESP_firewall_rules_name" {
  value = google_compute_firewall.ESP_firewall_rules[*].name
}
output "admin_password" {
  value = var.generatePassword ? [random_string.generated_password.result] : []
}


# Checkpoint MIG
output "MGN_SIC_key" {
  value = module.chk-mig.SIC_key
}
output "management_name" {
  value = var.management_name
}
output "configuration_template_name" {
  value = module.chk-mig.configuration_template_name
}
output "instance_template_name" {
  value = module.chk-mig.instance_template_name
}
output "instance_group_manager_name" {
  value = module.chk-mig.instance_group_manager_name
}
output "autoscaler_name" {
  value = module.chk-mig.autoscaler_name
}
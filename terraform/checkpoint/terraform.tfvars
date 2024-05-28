instance_name         = "mgn-win"
instance              = "windows"
app_domain            = "example.com"
gcp_zone              = "asia-south1-a"
windows_instance_type = "n2-standard-4"
image                 = "windows-cloud/windows-2019"
tags                  = ["rdp"]
labels                = { env = "common", application = "management" }
disk_size_gb          = "100"
disk_type_condition   = "pd-balanced"
vm_ipaddress          = "10.2.0.2"


## Checkpoint MGN
# --- Check Point Deployment---
image_name                 = "check-point-r8110-byol-335-883-v20210706"
installationType           = "Management only"
license                    = "BYOL"
prefix                     = "chk-mgn"
management_nic             = "Ephemeral Public IP (eth0)"
admin_shell                = "/bin/bash"
admin_SSH_key              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6e2kavFlt5SHqNTVzUquMvqh+B4TQBMCG3hwrgPnqB2HdF7eTBUdrhZem64cb/f7KA20Gw6qZtAd/9wa+XprKh1MoSetLLP7pWu+fBa8AuuvzzI5IsyJDwWVlr7+SXAF3/D/ZhtC2wcT8Hb0D38ftF03ZkJVcve/9EIjAK53tTbWgsLQz5W57OZBjjymLhpCkyf06VyYe8Zo9xorhSAWgrm05eBg1yU+rYeEIFjqsO0uFY9+ivZW08W9Fc4H+jR3zUv3SDnZDwLRFbdTp3Z2EbPSKh+fNB4iZ4psv0BUwJLzjqkgabpWLObrcmqTH4CuhqUCeutjI2Jbf3G8l0OHJsRBdkrM8AnyEd/qiVVVyw5ctnsuambAePPT5br2Ze6XBw7r1szSNyE6PAahfUNfjEBDQXvOp6D3ZfexJSQBNWqPmNQ5RmbWtamtrM9dK9LC2H1cdUW1W64nD+rvvRb6X0FbutvW5BJ6fIw4+dkOtw0SmAoC7Blhbb68ncu8CI/E= nikhil_pandit@mgn-win"
generatePassword           = true
sicKey                     = ""
managementGUIClientNetwork = "0.0.0.0/0"
checkpoint-sa              = "chk-sa"

# --- Networking---
zone       = "asia-south1-a"


# --- Instances configuration---
machine_type     = "n1-standard-8"
diskType         = "Balanced Persistent Disk"
bootDiskSizeGb   = "100"
enableMonitoring = "true" # Enable Stackdriver monitoring
chk_vm_ipaddress     = "10.2.0.3"



## Checkpoint MIG
mig_prefix                      = "check-point-gw"
configuration_template_name = "configs-gw"

management_name = "checkpoint-management"
mig_image_name      = "check-point-r8110-gw-byol-mig-335-985-v20220126"

external_network_name    = "vpc-external"
external_subnetwork_name = "sb-external-1"
internal_network_name    = "vpc-internal"
internal_subnetwork_name = "sb-internal-1"

mig_machine_type            = "n2-custom-4-24576"
cpu_usage               = "60"
instances_min_grop_size = "2"
instances_max_grop_size = "2"
internal_lb_ip          = "10.1.0.20"
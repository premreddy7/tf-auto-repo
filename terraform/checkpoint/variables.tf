variable "instance_name" {
  type        = string
  description = "This variable defines the name of the instance."
}

# domain name 
variable "app_domain" {
  type        = string
  description = "This variable defines the domain name used to build resources"
}


##############################
## GCP Provider - Variables ##
##############################

# define GCP region

variable "region" {
  type    = string
  default = "asia-south1"
}

# define GCP region
variable "gcp_zone" {
  type        = string
  description = "GCP zone"
}

################################
## GCP Windows VM - Variables ##
################################

variable "windows_instance_type" {
  type        = string
  description = "VM instance type"
  default     = "n2-standard-2"
}

variable "image" {
  type        = string
  description = "SKU for Windows Server (windows-cloud/windows-2012-r2, windows-cloud/windows-2016, windows-cloud/windows-2019, windows-cloud/windows-2022)."
  default     = "windows-cloud/windows-2022"
}

variable "tags" {
  type = list(string)
}

variable "disk_size_gb" {}

variable "disk_type_condition" {}

variable "labels" {
  type = map(string)
}

variable "instance" {}
variable "vm_ipaddress" {}


# Checkpoint MGN
variable "service_account_path" {
  type        = string
  description = "User service account path in JSON format - From the service account key page in the Cloud Console choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location is stored."
  default     = ""
}

variable "zone" {
  type        = string
  description = "The zone determines what computing resources are available and where your data is stored and used"
  default     = "asia-south1-a"
}
variable "image_name" {
  type        = string
  description = "The single gateway and management image name"
}
variable "installationType" {
  type        = string
  description = "Installation type and version"
  default     = "Gateway only"
}
variable "license" {
  type        = string
  description = "Checkpoint license (BYOL or PAYG)."
  default     = "BYOL"
}
variable "prefix" {
  type        = string
  description = "(Optional) Resources name prefix"
  default     = "chkp-single-tf-"
}
variable "machine_type" {
  type    = string
  default = "n1-standard-4"
}
variable "network_enableTcp" {
  type        = bool
  description = "Allow TCP traffic from the Internet"
  default     = false
}
variable "network_tcpSourceRanges" {
  type        = list(string)
  description = "Allow TCP traffic from the Internet"
  default     = []
}
variable "network_enableGwNetwork" {
  type        = bool
  description = "This is relevant for Management only. The network in which managed gateways reside"
  default     = false
}
variable "network_gwNetworkSourceRanges" {
  type        = list(string)
  description = "Allow TCP traffic from the Internet"
  default     = []
}
variable "network_enableIcmp" {
  type        = bool
  description = "Allow ICMP traffic from the Internet"
  default     = false
}
variable "network_icmpSourceRanges" {
  type        = list(string)
  description = "(Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ICMP traffic."
  default     = []
}
variable "network_enableUdp" {
  type        = bool
  description = "Allow UDP traffic from the Internet"
  default     = false
}
variable "network_udpSourceRanges" {
  type        = list(string)
  description = "(Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable UDP traffic."
  default     = []
}
variable "network_enableSctp" {
  type        = bool
  description = "Allow SCTP traffic from the Internet"
  default     = false
}
variable "network_sctpSourceRanges" {
  type        = list(string)
  description = "(Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable SCTP traffic."
  default     = []
}

variable "network_enableEsp" {
  type        = bool
  description = "Allow ESP traffic from the Internet	"
  default     = false
}
variable "network_espSourceRanges" {
  type        = list(string)
  description = "(Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ESP traffic."
  default     = []
}
variable "diskType" {
  type        = string
  description = "Disk type"
  default     = "pd-ssd"
}
variable "bootDiskSizeGb" {
  type        = number
  description = "Disk size in GB"
  default     = 100
}
variable "generatePassword" {
  type        = bool
  description = "Automatically generate an administrator password	"
  default     = false
}
variable "management_nic" {
  type        = string
  description = "Management Interface - Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1)."
  default     = "Ephemeral Public IP (eth0)"
}
variable "allowUploadDownload" {
  type        = string
  description = "Allow download from/upload to Check Point"
  default     = false
}
variable "enableMonitoring" {
  type        = bool
  description = "Enable Stackdriver monitoring"
  default     = false
}
variable "admin_shell" {
  type        = string
  description = "Change the admin shell to enable advanced command line configuration."
  default     = "/etc/cli.sh"
}
variable "admin_SSH_key" {
  type        = string
  description = "(Optional) The SSH public key for SSH authentication to the template instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default     = ""
}
variable "sicKey" {
  type        = string
  description = "The Secure Internal Communication one time secret used to set up trust between the single gateway object and the management server"
  default     = ""
}
variable "managementGUIClientNetwork" {
  type        = string
  description = "Allowed GUI clients	"
  default     = "0.0.0.0/0"
}
variable "numAdditionalNICs" {
  type        = number
  description = "Number of additional network interfaces"
  default     = 0
}
variable "externalIP" {
  type        = string
  description = "External IP address type"
  default     = "None"
}
variable "internal_network1_network" {
  type        = list(string)
  description = "1st internal network ID in the chosen zone."
  default     = []
}
variable "internal_network1_subnetwork" {
  type        = list(string)
  description = "1st internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network2_network" {
  type        = list(string)
  description = "2nd internal network ID in the chosen zone."
  default     = []
}
variable "internal_network2_subnetwork" {
  type        = list(string)
  description = "2nd internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network3_network" {
  type        = list(string)
  description = "3rd internal network ID in the chosen zone."
  default     = []
}
variable "internal_network3_subnetwork" {
  type        = list(string)
  description = "3rd internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network4_network" {
  type        = list(string)
  description = "4th internal network ID in the chosen zone."
  default     = []
}
variable "internal_network4_subnetwork" {
  type        = list(string)
  description = "4th internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network5_network" {
  type        = list(string)
  description = "5th internal network ID in the chosen zone."
  default     = []
}
variable "internal_network5_subnetwork" {
  type        = list(string)
  description = "5th internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network6_network" {
  type        = list(string)
  description = "6th internal network ID in the chosen zone."
  default     = []
}
variable "internal_network6_subnetwork" {
  type        = list(string)
  description = "6th internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network7_network" {
  type        = list(string)
  description = "7th internal network ID in the chosen zone."
  default     = []
}
variable "internal_network7_subnetwork" {
  type        = list(string)
  description = "7th internal subnet ID in the chosen network."
  default     = []
}
variable "internal_network8_network" {
  type        = list(string)
  description = "8th internal network ID in the chosen zone."
  default     = []
}
variable "internal_network8_subnetwork" {
  type        = list(string)
  description = "8th internal subnet ID in the chosen network."
  default     = []
}

variable "checkpoint-sa" {
  type        = string
  description = "The GCP Service account is used by the Check Point Security Management Server to monitor the creation and state of the autoscaling Managed Instance Group."
}

variable "chk_vm_ipaddress" {}


# Checkpoint MIG

variable "mig_prefix" {
  type        = string
  description = "Resources name prefix"
}

variable "mig_image_name" {
  type        = string
  description = "The autoscaling (MIG) image name (e.g. check-point-r8110-gw-byol-mig-335-985-v20220126). You can choose the desired mig image value from: https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/autoscale-byol/images.py"
  default     = "check-point-r8110-gw-byol-mig-335-985-v20220126"
}

variable "management_name" {
  type        = string
  description = "The name of the Security Management Server as appears in autoprovisioning configuration. (Please enter a valid Security Management name including ascii characters only)"
  default     = "checkpoint-management"
}
variable "configuration_template_name" {
  type        = string
  description = "Specify the provisioning configuration template name (for autoprovisioning). (Please enter a valid autoprovisioing configuration template name including ascii characters only)"
  default     = ""
}

variable "allow_upload_download" {
  type        = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default     = true
}

variable "external_network_name" {
  type        = string
  description = "The network determines what network traffic the instance can access"
}
variable "external_subnetwork_name" {
  type        = string
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
}
variable "internal_network_name" {
  type        = string
  description = "The network determines what network traffic the instance can access"
}
variable "internal_subnetwork_name" {
  type        = string
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
}

# --- Instance Configuration ---
variable "mig_machine_type" {
  type    = string
  default = "n2-custom-6-24576"
}
variable "cpu_usage" {
  type        = number
  description = "Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance."
  default     = 60
}

variable "instances_min_grop_size" {
  type        = number
  description = "The minimal number of instances"
  default     = 2
}
variable "instances_max_grop_size" {
  type        = number
  description = "The maximal number of instances"
  default     = 10
}
variable "disk_type" {
  type        = string
  description = "Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency."
  default     = "Balanced Persistent Disk"
}
variable "disk_size" {
  type        = number
  description = "Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space."
  default     = 100
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable Stackdriver monitoring"
  default     = true
}

variable "port_name" {
  description = "The named port configuration."
  default     = "tcp"
}

variable "port" {
  description = "port number"
  default     = "8117"
}

variable "internal_lb_ip" {
  description = "Load Balancer ip"
  default     = null
}


#variable "ddos_policy_rules" {
#  description = "default rule"
#  default = {
#    ddos_rule = {
#      action         = "allow"
#      priority       = "1000"
#      versioned_expr = "SRC_IPS_V1"
#      src_ip_ranges  = ["*"]
#      description    = "default rule"
#    }
#  }
#  type = map(object({
#    action         = string
#    priority       = string
#    versioned_expr = string
#    src_ip_ranges  = list(string)
#    description    = string
#    })
#  )
#}

variable "port_details" {
  default = [
    {
      name = "https"
      port = "8443"
  }]
}

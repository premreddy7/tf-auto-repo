variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = null
}

variable "nlb" {
  description = "Internal Load Balancer"
}

variable "mig" {
  description = "Managed instance group"
}

variable "region" {
  description = "nlb region"
}


variable "protocol" {
  description = "nlb protocol"
}

variable "load_balancing_scheme" {
  description = "load balancing scheme"
}


variable "network" {
  description = "vpc network"
}

variable "subnetwork" {
  description = "vpc subnetwork"
}

variable "hc" {
  description = "Health check"
}

variable "lb_ip" {
  description = "Load Balancer ip"
}

variable "all_ports" {
  description = "Set this field to true to allow packets addressed to any port or packets lacking destination port information to be forwarded to the backends configured with this forwarding rule"
  type        = bool
  default     = true
}

variable "ports" {
  description = "Set this field to true to allow packets addressed to any port or packets lacking destination port information to be forwarded to the backends configured with this forwarding rule"
  type        = list(string)
  default     = null
}


variable "connection_draining_timeout_sec" {
  default = 300
}

variable "allow_global_access" {
  default = false
}
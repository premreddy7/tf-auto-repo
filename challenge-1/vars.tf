variable "app" {
  type    = string
  default = "tier3-app"
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "target_size" {
  type    = string
  default = "1"
}

variable "project" {
  type    = string
  default = "<project>"
}

variable "db_ver" {
  default = "MYSQL_5_7"
}

variable "cidr" {
  default = "192.168.0.0/24"
}

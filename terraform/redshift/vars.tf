## Global
variable "prefix" {
  description = "A prefix used in the name for all the resources created by this script. The prefix string must start with lowercase letter and contain only alphanumeric characters."
  type        = string
}

variable "aws_environment" {
  type = map(string)
  default = {
    dev  = "dev"
    test = "test"
    impl = "impl"
    prod = "prod"
  }
}

variable "aws_layer" {
  type = map(string)
  default = {
    "app"     = "app"
    "data"    = "data"
    "private" = "private"
  }
}
/*variable "cluster_parameter_group" {
  description = "Parameter group, depends on DB engine used"
  type        = string
  default     = "ospr"
}*/

variable "region" {

}

variable "rs_db_name" {

}

variable "rs_node_tpye" {
  default = "dc2.large"
}

variable "rs_cluster_type" {

}

variable "number_of_nodes" {

}

variable "tags" {

}
variable "ec2_tag" {

}

variable "redshift_role" {

}

variable "proxy_instance_role" {

}

variable "proxy_instance_type" {

}

variable "tableau_cidr" {
  type = list(string)
}

variable "edl_workspace_cidr" {
  type = list(string)
}

variable "edl_govcloud_hive_metastore_cidr" {
  type = list(string)
}

variable "tableau_govcloud_ospr_redshift_cidr" {
  type = list(string)
}

variable "ospr_load_balancer_cidr" {
  type = list(string)
}

variable "edl_commercial_data_cidr" {
  type = list(string)
}

variable "hbi_db_arn" {

}

variable "glue_role" {

}

variable "edl_role" {

}
variable "coin_bucket" {

}
variable "port_sg" {

}


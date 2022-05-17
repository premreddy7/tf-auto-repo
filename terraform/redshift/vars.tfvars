## Global
prefix                              = "ospr-coin"
region                              = "us-gov-west-1"
rs_db_name                          = "coinrsdb"
rs_node_tpye                        = "dc2.large"
rs_cluster_type                     = "multi-node"
number_of_nodes                     = "2"
tags                                = { project_name = "coin", environment = "dev" }
redshift_role                       = "arn:aws-us-gov:iam::169669953619:role/ospr-redshift-role"
proxy_instance_type                 = "t2.micro"
tableau_cidr                        = ["10.240.32.32/27"]
edl_workspace_cidr                  = ["10.252.250.0/25", "10.252.250.128/25", "10.252.251.0/25"]
edl_govcloud_hive_metastore_cidr    = ["10.239.214.0/25", "10.239.214.128/25", "10.239.215.0/25", "52.5.212.71/32"]
ospr_load_balancer_cidr             = ["10.240.35.0/27", "10.240.35.32/27"]
tableau_govcloud_ospr_redshift_cidr = ["10.239.130.0/25", "10.239.130.128/25", "10.239.131.0/25"]
edl_commercial_data_cidr            = ["10.223.32.32/28", "10.223.32.48/28"]
ec2_tag                             = { project_name = "coin", environment = "dev", "Patch Group" = "Amazon_Linux", "cpm backup" = "Daily" }
hbi_db_arn                          = "arn:aws-us-gov:secretsmanager:us-gov-west-1:169669953619:secret:hbi_incorta"
proxy_instance_role                 = "cms-cloud-base-ec2-profile-v4"
glue_role                           = "arn:aws-us-gov:iam::169669953619:role/delegatedadmin/developer/AWSGlueServiceRole"
edl_role                            = "arn:aws-us-gov:iam::171289172860:role/delegatedadmin/developer/edl-govcloud-dataops"
coin_bucket                         = "ospr-coin-dev"
port_sg                             = "5439"

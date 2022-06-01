provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-code-backend-state-bucket"
    region = "us-east-2"
  }
}

module "redshift" {
  source           = "../../modules/redshift"
  coinrs_cred_name = "coin_rs_creds1"

  redshift_cluster = {
    privacera-rs = {
      cluster_identifier                  = "privacera-rs"
      rs_db_name                          = "coinrsdb"
      rs_node_tpye                        = "dc2.large"
      rs_cluster_type                     = "multi-node"
      number_of_nodes                     = "2"
      automated_snapshot_retention_period = "30"
      cluster_parameter_group_name        = "ospr"
      skip_final_snapshot                 = true
      tags                                = { project_name = "coin", environment = "dev" }
      iam_roles                           = ["arn:aws:iam::517446614341:role/first_glue_job_test"]
      publicly_accessible                 = false
      rshift_subnet_group                 = "ospr-coin-rs-subnet-group"
      rshift_subnet_group_subnet_ids      = [data.aws_subnet.private_1a.id, data.aws_subnet.private_1b.id]
    }
  }

  rshift_para_group = {
    ospr = {
      name   = "ospr"
      family = "redshift-1.0"
      parameters = [
        {
          name  = "require_ssl"
          value = "true"
        },
        {
          name  = "enable_user_activity_logging"
          value = "true"
        },
        {
          name  = "auto_analyze"
          value = "true"
        },
        {
          name  = "datestyle"
          value = "ISO,MDY"
        },
        {
          name  = "enable_case_sensitive_identifier"
          value = "false"
        },
        {
          name  = "extra_float_digits"
          value = "0"
        },
        {
          name  = "search_path"
          value = "$user, public"
        },
        {
          name  = "statement_timeout"
          value = "0"
        },
        {
          name  = "use_fips_ssl"
          value = "false"
        }
      ]
    }
  }

  s3_details = {
    ospr-coin-dev = {
      name                    = "ospr-coin-dev-fdsg32"
      versioning              = true
      tags                    = { project_name = "coin", environment = "dev" }
      kms_key_name            = "alias/ospr-key-alias"
      block_public_acls       = true
      block_public_policy     = true
      restrict_public_buckets = true
      ignore_public_acls      = true
    }
  }

  lb_config = {
    lb1 = {
      lb_name            = "edl-com-priv-to-ospr-gov-rs-lb"
      lb_subnets         = [data.aws_subnet.data_a.id, data.aws_subnet.data_b.id]
      vpc_id             = data.aws_vpc.default.id
      internal           = true
      load_balancer_type = "network"
      lb_tags            = { project_name = "coin", environment = "dev" }
      lst_port           = "5439"
      lst_protocol       = "TCP"
      lst_type           = "forward"
      lb_tg_grp_name     = "edl-com-priv-to-ospr-gov-rs-tg"
      lb_tg_grp_port     = "5439"
      lb_tg_grp_protocol = "TCP"
    }
  }
  dns_conf = {
    zone_name   = "coin.cmscloud.local"
    vpc_id      = data.aws_vpc.default.id
    record_name = "trans-proxy"
    type        = "A"
    ttl         = "300"
  }

  route53_records = [data.aws_network_interface.trans_1a.private_ip, data.aws_network_interface.trans_1b.private_ip]

  glue_conn_details = {
    incorta_conn = {
      name      = "incorta"
      engine    = local.hbi_db_creds.engine
      host      = local.hbi_db_creds.host
      port      = local.hbi_db_creds.port
      dbname    = local.hbi_db_creds.dbname
      password  = local.hbi_db_creds.password
      username  = local.hbi_db_creds.username
      az        = data.aws_subnet.private_1a.availability_zone
      subnet_id = data.aws_subnet.private_1a.id
    }
  }

  instance_details = {
    proxy_1a = {

      instance_type            = "t2.micro"
      ec2_ami                  = data.aws_ami.amzn2_gi.id
      ec2_network_interface_id = data.aws_network_interface.trans_1a.id
      iam_instance_profile     = "cms-cloud-base-ec2-profile-v4"
      disable_api_termination  = false
      ebs_optimized            = false
      get_password_data        = false
      hibernation              = false
      monitoring               = false
      user_data                = "scripts/proxy_user_data.sh"
      ec2_tag = {
      project_name = "coin", environment = "dev", "Patch Group" = "Amazon_Linux", "cpm backup" = "Daily" , Name="proxy-1a"}

    },
    proxy_1b = {
      instance_type            = "t2.micro"
      ec2_ami                  = data.aws_ami.amzn2_gi.id
      ec2_network_interface_id = data.aws_network_interface.trans_1b.id
      iam_instance_profile     = "cms-cloud-base-ec2-profile-v4"
      disable_api_termination  = false
      ebs_optimized            = false
      get_password_data        = false
      hibernation              = false
      monitoring               = false
      user_data                = "scripts/proxy_user_data.sh"
      ec2_tag                  = { project_name = "coin", environment = "dev", "Patch Group" = "Amazon_Linux", "cpm backup" = "Daily", Name="proxy-1b" }
    }
  }

  sec_group = {
    ospr-coin-redshift-sg = {
      name        = "ospr-coin-redshift-sg"
      vpc_id      = data.aws_vpc.default.id
      tags        = { Name = "ospr-coin-redshift-sg", project_name = "coin", environment = "dev" }
      description = "all inbound rules to redshift"
      sec_ingress_rule = [

        {
          description      = "tableau govcloud to ospr redshift"
          from_port        = 5439
          to_port          = 5439
          protocol         = "tcp"
          cidr_blocks      = ["10.240.32.32/27"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        },
        {
          description      = "edl hive metastore govcloud to ospr redshift"
          from_port        = 5439
          to_port          = 5439
          protocol         = "tcp"
          cidr_blocks      = ["10.239.214.0/25", "10.239.214.128/25", "10.239.215.0/25", "52.5.212.71/32"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        },
        {
          description      = "ospr load balancer"
          from_port        = 5439
          to_port          = 5439
          protocol         = "tcp"
          cidr_blocks      = [data.aws_subnet.data_a.cidr_block, data.aws_subnet.data_b.cidr_block]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = false
        },
        {
          description      = "tableau govcloud to ospr"
          from_port        = 5439
          to_port          = 5439
          protocol         = "tcp"
          cidr_blocks      = ["10.239.130.0/25", "10.239.130.128/25", "10.239.131.0/25"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = false
        },

        {
          description      = "edl commercial data"
          from_port        = 5439
          to_port          = 5439
          protocol         = "tcp"
          cidr_blocks      = ["10.223.32.32/28", "10.223.32.48/28"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = false
        },

        {
          description      = "ospr glue job to ospr redshift"
          from_port        = 5439
          to_port          = 5439
          protocol         = "tcp"
          cidr_blocks      = [data.aws_subnet.private_1a.cidr_block]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = false
        }
      ]
      sec_egress_rule = [
        {
          description      = "redshift outbound"
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        }
      ]
    },

    ospr-coin-proxy_sg = {
      name        = "ospr-coin-proxy_sg"
      vpc_id      = data.aws_vpc.default.id
      description = "all inbound rules to proxy"
      tags        = { Name = "ospr-coin-proxy_sg", project_name = "coin", environment = "dev" }
      sec_ingress_rule = [
        {
          description      = "glue connection to incorta hbi proxy"
          from_port        = local.hbi_db_creds.port
          to_port          = local.hbi_db_creds.port
          protocol         = "tcp"
          cidr_blocks      = [data.aws_subnet.private_1a.cidr_block, data.aws_subnet.private_1b.cidr_block]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        }
      ]

      sec_egress_rule = [
        {
          description      = "proxy outbound"
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        }
      ]
    },
    ospr-coin-incorta_sg = {
      name        = "ospr-coin-incorta-sg"
      tags        = { Name = "ospr-coin-incorta_sg", project_name = "coin", environment = "dev" }
      vpc_id      = data.aws_vpc.default.id
      description = "all inbound rules to incorta"
      sec_ingress_rule = [
        {
          description      = "self - required for glue conneciton to work"
          from_port        = 0
          to_port          = 65535
          protocol         = "tcp"
          cidr_blocks      = null
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = true
        },
        {
          description      = "glue to incorta"
          from_port        = local.hbi_db_creds.port
          to_port          = local.hbi_db_creds.port
          protocol         = "tcp"
          cidr_blocks      = [data.aws_subnet.private_1a.cidr_block, data.aws_subnet.private_1b.cidr_block]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        }
      ]
      sec_egress_rule = [
        {
          description      = "incorta outbound"
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        }
      ]
    }
  }
}

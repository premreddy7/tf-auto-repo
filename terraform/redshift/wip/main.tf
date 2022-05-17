provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-code-backend-state-bucket"
    region = "us-east-2"
    key    = "env/dev/redshift/default"
  }
}

module "redshift" {
  source           = "../../modules/wip-redshift"
  coinrs_cred_name = "coin_rs_creds"
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
      user_data                = "proxy_user_data.sh"
      ec2_tag = {
      project_name = "coin", environment = "dev", "Patch Group" = "Amazon_Linux", "cpm backup" = "Daily" }

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
      user_data                = "proxy_user_data.sh"
      ec2_tag                  = { project_name = "coin", environment = "dev", "Patch Group" = "Amazon_Linux", "cpm backup" = "Daily" }
    }
  }

  sec_group = {
    ospr-coin-redshift-sg = {
      name        = "ospr-coin-redshift-sg"
      vpc_id      = data.aws_vpc.default.id
      tags        = { project_name = "coin", environment = "dev" }
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
      tags        = { project_name = "coin", environment = "dev" }
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
      tags        = { project_name = "coin", environment = "dev" }
      vpc_id      = data.aws_vpc.default.id
      description = "all inbound rules to incorta"
      tags        = {}
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

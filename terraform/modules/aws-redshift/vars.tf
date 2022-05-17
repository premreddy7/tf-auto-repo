variable "redshift_cluster" {
  type = map(object({
    cluster_identifier                  = string
    rs_db_name                          = string
    rs_node_tpye                        = string
    rs_cluster_type                     = string
    number_of_nodes                     = list(string)
    automated_snapshot_retention_period = string
    cluster_parameter_group_name        = string
    skip_final_snapshot                 = string
    tags                                = string
    iam_roles                           = string
    publicly_accessible                 = string
    })
  )
}

variable "rshift_para_group" {
  type = list(map(string))
  default = [
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


variable "sec_group" {
  type = map(object({
    name        = string
    description = string
    vpc_id      = string
    tags        = string
    sec_ingress_rule = list(object({
      description      = string
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
      prefix_list_ids  = string
      security_groups  = string
      self             = string
    }))
    sec_egress_rule = list(object({
      description      = string
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
      prefix_list_ids  = string
      security_groups  = string
      self             = string
    }))
  }))

  default = {
    sec-grp1 = {
      name        = "test"
      description = "demo"
      vpc_id      = "test"
      sec_ingress_rule = [

        {
          description      = "tableau govcloud to ospr redshift"
          from_port        = var.port_sg
          to_port          = var.port_sg
          protocol         = "tcp"
          cidr_blocks      = var.tableau_cidr
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        },

        {
          description      = "edl hive metastore govcloud to ospr redshift"
          from_port        = var.port_sg
          to_port          = var.port_sg
          protocol         = "tcp"
          cidr_blocks      = var.edl_govcloud_hive_metastore_cidr
          ipv6_cidr_blocks = null
          prefix_list_ids  = null
          security_groups  = null
          self             = null
        },

        {
          cidr_blocks      = ["${data.aws_subnet.data_a.cidr_block}", "${data.aws_subnet.data_b.cidr_block}"]
          description      = "ospr load balancer"
          from_port        = var.port_sg
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "tcp"
          security_groups  = []
          self             = false
          to_port          = var.port_sg
        },

        {
          cidr_blocks      = var.tableau_govcloud_ospr_redshift_cidr
          description      = "tableau govcloud to ospr redshift  private cidr"
          from_port        = var.port_sg
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "tcp"
          security_groups  = []
          self             = false
          to_port          = var.port_sg

        },

        {
          cidr_blocks      = var.edl_commercial_data_cidr
          description      = "edl commercial data"
          from_port        = var.port_sg
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "tcp"
          security_groups  = []
          self             = false
          to_port          = var.port_sg

        },

        {
          cidr_blocks      = ["${data.aws_subnet.private_1a.cidr_block}"]
          description      = "ospr glue job to ospr redshift"
          from_port        = var.port_sg
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "tcp"
          security_groups  = []
          self             = false
          to_port          = var.port_sg

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


    proxy_sg = {
      name        = "${var.prefix}-proxy-sg"
      description = "all inbound rules to proxy"
      vpc_id      = data.aws_vpc.default.id
      tags        = ""
      sec_ingress_rule = [
        {
          description      = "glue connection to incorta hbi proxy"
          from_port        = local.hbi_db_creds.port
          to_port          = local.hbi_db_creds.port
          protocol         = "tcp"
          cidr_blocks      = ["${data.aws_subnet.private_1a.cidr_block}", "${data.aws_subnet.private_1b.cidr_block}"]
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
    incorta_sg = {
      name        = "${var.prefix}-incorta-sg"
      description = "all inbound rules to incorta"
      vpc_id      = data.aws_vpc.default.id
      tags        = ""
      sec_ingress_rule = [
        {
          description = "self - required for glue conneciton to work"
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          self        = true
        },
        {
          description      = "glue to incorta"
          from_port        = local.hbi_db_creds.port
          to_port          = local.hbi_db_creds.port
          protocol         = "tcp"
          cidr_blocks      = ["${data.aws_subnet.private_1a.cidr_block}", "${data.aws_subnet.private_1b.cidr_block}"]
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

variable "instance_details" {
  type = map(object({
    instance_type           = string
    iam_instance_profile    = string
    disable_api_termination = string
    ebs_optimized           = string
    get_password_data       = list(string)
    hibernation             = string
    monitoring              = string
    user_data               = string
    ec2_tag                 = string
    })
  )
  default = {

    ec1 = {
      instance_type           = ""
      iam_instance_profile    = ""
      disable_api_termination = false
      ebs_optimized           = false
      get_password_data       = false
      hibernation             = false
      monitoring              = false
      user_data               = proxy_user_data.sh
      ec2_tag                 = ""

    },

    ec2 = {
      instance_type           = ""
      iam_instance_profile    = ""
      disable_api_termination = false
      ebs_optimized           = false
      get_password_data       = false
      hibernation             = false
      monitoring              = false
      user_data               = proxy_user_data.sh
      ec2_tag                 = ""

    }

  }
}




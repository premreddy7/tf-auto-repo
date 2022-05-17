provider "aws" {
  region = var.region
}
##### redshift password and hbi connection configuration details begin #####

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@!"
}

resource "aws_secretsmanager_secret" "coinrscred" {
  name = "coin_rs_creds"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.coinrscred.id
  secret_string = <<EOF
   {
    "username": "admin",
    "password": "${random_password.password.result}"
   }
EOF
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

locals {
  hbi_db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.hbi_creds.secret_string
  )
}

##### redshift password and hbi connection configuration details end #####

##### Redshift cluster configuration configuration details begin #####

resource "aws_redshift_subnet_group" "default" {
  name       = "${var.prefix}-rs-subnet-group"
  subnet_ids = [data.aws_subnet.private_1a.id, data.aws_subnet.private_1b.id]

  tags = var.tags

}

resource "aws_redshift_cluster" "default" {
  cluster_identifier                  = "${var.prefix}-rs-cluster"
  database_name                       = var.rs_db_name
  master_username                     = local.db_creds.username
  master_password                     = local.db_creds.password
  node_type                           = var.rs_node_tpye
  cluster_type                        = var.rs_cluster_type
  number_of_nodes                     = var.number_of_nodes
  automated_snapshot_retention_period = 30
  cluster_subnet_group_name           = aws_redshift_subnet_group.default.id
  cluster_parameter_group_name        = "ospr"
  vpc_security_group_ids              = [aws_security_group.redshift.id, data.aws_security_group.cloudvpn.id]
  skip_final_snapshot                 = true
  tags                                = var.tags
  iam_roles                           = [var.redshift_role]
  publicly_accessible                 = false
}

resource "aws_redshift_cluster" "pricaverapoc" {
  count = var.aws_environment == "dev" ? 1 : 0

  cluster_identifier                  = "privacera-rs"
  database_name                       = var.rs_db_name
  master_username                     = local.db_creds.username
  master_password                     = local.db_creds.password
  node_type                           = var.rs_node_tpye
  cluster_type                        = var.rs_cluster_type
  automated_snapshot_retention_period = 30
  cluster_subnet_group_name           = aws_redshift_subnet_group.default.id
  cluster_parameter_group_name        = "ospr"
  vpc_security_group_ids              = [aws_security_group.redshift.id, data.aws_security_group.cloudvpn.id]
  skip_final_snapshot                 = true
  tags                                = var.tags
  iam_roles                           = [var.redshift_role]
  publicly_accessible                 = false
}
resource "aws_redshift_parameter_group" "par" {
  name   = "ospr"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
  parameter {
    name  = "auto_analyze"
    value = "true"
  }
  parameter {
    name  = "datestyle"
    value = "ISO,MDY"
  }
  parameter {
    name  = "enable_case_sensitive_identifier"
    value = "false"
  }
  parameter {
    name  = "extra_float_digits"
    value = "0"
  }
  parameter {
    name  = "search_path"
    value = "$user, public"
  }
  parameter {
    name  = "statement_timeout"
    value = "0"
  }
  parameter {
    name  = "use_fips_ssl"
    value = "false"
  }
}

resource "aws_security_group" "redshift" {
  name        = "${var.prefix}-redshift-sg"
  description = "all inbound rules to redshift"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "tableau govcloud to ospr redshift"
    from_port        = var.port_sg
    to_port          = var.port_sg
    protocol         = "tcp"
    cidr_blocks      = var.tableau_cidr
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }


  ingress {
    description      = "edl hive metastore govcloud to ospr redshift"
    from_port        = var.port_sg
    to_port          = var.port_sg
    protocol         = "tcp"
    cidr_blocks      = var.edl_govcloud_hive_metastore_cidr
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }

  ingress {
    cidr_blocks      = ["${data.aws_subnet.data_a.cidr_block}", "${data.aws_subnet.data_b.cidr_block}"]
    description      = "ospr load balancer"
    from_port        = var.port_sg
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = var.port_sg
  }
  ingress {
    cidr_blocks      = var.tableau_govcloud_ospr_redshift_cidr
    description      = "tableau govcloud to ospr redshift  private cidr"
    from_port        = var.port_sg
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = var.port_sg

  }

  ingress {
    cidr_blocks      = var.edl_commercial_data_cidr
    description      = "edl commercial data"
    from_port        = var.port_sg
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = var.port_sg

  }
  ingress {
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

  egress = [
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

  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

##### Redshift cluster configuration details end #####

##### S3 bucket configuration configuration details begin #####

resource "aws_kms_key" "ospr_s3_key" {
  description = "KMS key for s3"
  tags        = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_kms_alias" "ospr_s3_key" {
  name          = "alias/ospr-key-alias"
  target_key_id = aws_kms_key.ospr_s3_key.key_id

  lifecycle {
    ignore_changes = all
  }
}


resource "aws_s3_bucket" "coin" {
  bucket = var.coin_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.ospr_s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = var.tags

}

resource "aws_s3_bucket_public_access_block" "coin-s3Public" {
  bucket                  = aws_s3_bucket.coin.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

##### S3 bucket configuration details end #####

##### Glue configuration configuration details begin #####

resource "aws_glue_connection" "incorta_conn" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:${local.hbi_db_creds.engine}://${local.hbi_db_creds.host}:${local.hbi_db_creds.port}/${local.hbi_db_creds.dbname}"
    PASSWORD            = local.hbi_db_creds.password
    USERNAME            = local.hbi_db_creds.username
  }

  name = "incorta"

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.private_1a.availability_zone
    security_group_id_list = [aws_security_group.incorta_sg.id]
    subnet_id              = data.aws_subnet.private_1a.id
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_security_group" "incorta_sg" {
  name        = "${var.prefix}-incorta-sg"
  description = "all inbound rules to incorta"
  vpc_id      = data.aws_vpc.default.id

  ingress {
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

  ingress {
    description = "self - required for glue conneciton to work"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress = [
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

  tags = var.tags
}

##### Glue configuration configuration details end #####

##### Transport Proxy Instances configuration configuration details begin #####

resource "aws_instance" "proxy_1a" {
  ami                     = data.aws_ami.amzn2_gi.id
  instance_type           = var.proxy_instance_type
  iam_instance_profile    = var.proxy_instance_role
  disable_api_termination = false
  ebs_optimized           = false
  get_password_data       = false
  hibernation             = false
  monitoring              = false

  user_data = file("proxy_user_data.sh")

  network_interface {
    network_interface_id = data.aws_network_interface.trans_1a.id
    device_index         = 0
  }

  lifecycle {
    ignore_changes = [
      ami,
      instance_type,
      user_data,
      tags
    ]
  }
  tags = var.ec2_tag
}

resource "aws_instance" "proxy_1b" {
  ami                     = data.aws_ami.amzn2_gi.id
  instance_type           = var.proxy_instance_type
  iam_instance_profile    = var.proxy_instance_role
  disable_api_termination = false
  ebs_optimized           = false
  get_password_data       = false
  hibernation             = false
  monitoring              = false


  user_data = file("proxy_user_data.sh")
  network_interface {
    network_interface_id = data.aws_network_interface.trans_1b.id
    device_index         = 0
  }
  lifecycle {
    ignore_changes = [
      ami,
      instance_type,
      user_data,
      tags
    ]
  }

  tags = var.ec2_tag
}

resource "aws_security_group" "proxy_sg" {
  name        = "${var.prefix}-proxy-sg"
  description = "all inbound rules to proxy"
  vpc_id      = data.aws_vpc.default.id

  ingress = [
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

  egress = [
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

  tags = var.tags
}

##### Transport Proxy Instances configuration configuration details end #####

##### data nlb configuration details begin #####

resource "aws_lb" "redshift_nlb" {
  name               = "edl-com-priv-to-ospr-gov-rs-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [data.aws_subnet.data_a.id, data.aws_subnet.data_b.id]

  enable_deletion_protection = true

  tags = var.tags
}

resource "aws_lb_listener" "redshift_listener" {
  load_balancer_arn = aws_lb.redshift_nlb.arn
  port              = "5439"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redshift_tg.arn
  }
}

resource "aws_lb_target_group" "redshift_tg" {
  name     = "edl-com-priv-to-ospr-gov-rs-tg"
  port     = 5439
  protocol = "TCP"
  vpc_id   = data.aws_vpc.default.id
}


##### data nlb configuration details end#####

##### Route53 configuration configuration details begin #####

resource "aws_route53_zone" "private" {
  name = "coin.cmscloud.local"

  vpc {
    vpc_id = data.aws_vpc.default.id
  }
}

resource "aws_route53_record" "proxy-record" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "trans-proxy"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_network_interface.trans_1a.private_ip}", "${data.aws_network_interface.trans_1b.private_ip}"]
}

##### Route53 configuration configuration details end #####
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
  tags       = var.tags

}

resource "aws_redshift_cluster" "default" {
  for_each                            = var.redshift_cluster
  cluster_identifier                  = each.value.cluster_identifier
  database_name                       = each.value.rs_db_name
  master_username                     = local.db_creds.username
  master_password                     = local.db_creds.password
  node_type                           = each.value.rs_node_tpye
  cluster_type                        = each.value.rs_cluster_type
  number_of_nodes                     = each.value.number_of_nodes
  automated_snapshot_retention_period = each.value.automated_snapshot_retention_period
  cluster_subnet_group_name           = aws_redshift_subnet_group.default.id
  cluster_parameter_group_name        = each.value.cluster_parameter_group_name
  vpc_security_group_ids              = [aws_security_group.redshift.id, data.aws_security_group.cloudvpn.id]
  skip_final_snapshot                 = each.value.skip_final_snapshot
  tags                                = each.value.tags
  iam_roles                           = each.value.iam_roles
  publicly_accessible                 = each.value.publicly_accessible
}


resource "aws_redshift_parameter_group" "par" {
  name   = "ospr"
  family = "redshift-1.0"
  dynamic "parameter" {
    for_each = var.rshift_para_group
    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }
}

resource "aws_security_group" "redshift" {
  for_each    = var.sec_group
  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = each.value.sec_ingress_rule
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      prefix_list_ids  = ingress.value.prefix_list_ids
      security_groups  = ingress.value.security_groups
      self             = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = each.value.sec_egress_rule
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      prefix_list_ids  = egress.value.prefix_list_ids
      security_groups  = egress.value.security_groups
      self             = egress.value.self
    }
  }

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
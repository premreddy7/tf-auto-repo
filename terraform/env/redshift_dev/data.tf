data "aws_vpc" "default" {
  tags = {
    stack = var.env
  }
}

data "aws_subnet" "data_a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}a"
  tags = {
    stack = var.env
    use   = "data"
  }
}

data "aws_subnet" "data_b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}b"
  tags = {
    stack = var.env
    use   = "data"
  }
}

data "aws_subnet" "private_1a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}a"
  tags = {
    stack = var.env
    use   = "private"
  }
}

data "aws_subnet" "private_1b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}b"
  tags = {
    stack = var.env
    use   = "private"
  }
}


data "aws_network_interface" "trans_1a" {

  filter {
    name   = "availability-zone"
    values = ["us-east-2a"]
  }

  filter {
    name   = "description"
    values = ["hbi-connectivity"]
  }
}

data "aws_network_interface" "trans_1b" {

  filter {
    name   = "availability-zone"
    values = ["us-east-2b"]
  }
  filter {
    name   = "description"
    values = ["hbi-connectivity"]
  }
}

data "aws_ami" "amzn2_gi" {
  most_recent = true
  name_regex  = "amzn2-ami-kernel-5.10-hvm-2.0.20220406.1-x86_64-gp2"
  owners      = ["137112412989"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_secretsmanager_secret_version" "hbi_creds" {
  secret_id = var.hbi_db_arn
}

locals {
  hbi_db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.hbi_creds.secret_string
  )
}
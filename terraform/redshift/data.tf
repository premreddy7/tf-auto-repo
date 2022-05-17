data "aws_ami" "amzn2_gi" {
  most_recent = true
  name_regex  = "^amzn2-gi-\\d{3}"
  owners      = ["021568039808"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  tags = {
    stack = "${lookup(var.aws_environment, terraform.workspace)}"
  }
}

data "aws_subnet" "private_1a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}a"
  tags = {
    stack = "${lookup(var.aws_environment, terraform.workspace)}"
    use   = "private"
  }
}

data "aws_subnet" "private_1b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}b"
  tags = {
    stack = "${lookup(var.aws_environment, terraform.workspace)}"
    use   = "private"
  }
}

data "aws_subnet" "data_a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}a"
  tags = {
    stack = "${lookup(var.aws_environment, terraform.workspace)}"
    use   = "data"
  }
}

data "aws_subnet" "data_b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}b"
  tags = {
    stack = "${lookup(var.aws_environment, terraform.workspace)}"
    use   = "data"
  }
}

data "aws_secretsmanager_secret" "coinrscred" {
  arn = aws_secretsmanager_secret.coinrscred.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.coinrscred.arn
}

data "aws_secretsmanager_secret_version" "hbi_creds" {
  secret_id = var.hbi_db_arn
}

data "aws_security_group" "cloudvpn" {
  name = "cmscloud-vpn"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_network_interface" "trans_1a" {

  filter {
    name   = "availability-zone"
    values = ["us-gov-west-1a"]
  }

  filter {
    name   = "description"
    values = ["hbi-connectivity"]
  }
}

data "aws_network_interface" "trans_1b" {

  filter {
    name   = "availability-zone"
    values = ["us-gov-west-1b"]
  }
  filter {
    name   = "description"
    values = ["hbi-connectivity"]
  }
}


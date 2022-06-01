data "aws_secretsmanager_secret" "coinrscred" {
  arn = aws_secretsmanager_secret.coinrscred.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.coinrscred.arn
}

data "aws_security_group" "cloudvpn" {
  name = "cmscloud-vpn"
}
###
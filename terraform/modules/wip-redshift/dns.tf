
##### Route53 configuration configuration details begin #####

resource "aws_route53_zone" "private" {
  name = var.dns_conf["zone_name"]
  vpc {
    vpc_id = var.dns_conf["vpc_id"]
  }
}

resource "aws_route53_record" "proxy-record" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.dns_conf["record_name"]
  type    = var.dns_conf["type"]
  ttl     = var.dns_conf["ttl"]
  records = var.route53_records
}

##### Route53 configuration configuration details end #####
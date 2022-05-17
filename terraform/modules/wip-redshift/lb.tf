##### data nlb configuration details begin #####

resource "aws_lb" "redshift_nlb" {
  for_each                   = var.lb_config
  name                       = each.value.lb_name
  internal                   = each.value.internal
  load_balancer_type         = each.value.load_balancer_type
  subnets                    = each.value.lb_subnets
  enable_deletion_protection = true
  tags                       = each.value.lb_tags
}

resource "aws_lb_listener" "redshift_listener" {
  for_each          = var.lb_config
  load_balancer_arn = aws_lb.redshift_nlb[each.key].arn
  port              = each.value.lst_port
  protocol          = each.value.lst_protocol

  default_action {
    type             = each.value.lst_type
    target_group_arn = aws_lb_target_group.redshift_tg[each.key].arn
  }
}

resource "aws_lb_target_group" "redshift_tg" {
  for_each = var.lb_config
  name     = each.value.lb_tg_grp_name
  port     = each.value.lb_tg_grp_port
  protocol = each.value.lb_tg_grp_protocol
  vpc_id   = each.value.vpc_id
}

##### data nlb configuration details end#####
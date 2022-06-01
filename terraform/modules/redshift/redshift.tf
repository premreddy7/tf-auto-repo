##### Redshift cluster configuration configuration details begin #####

resource "aws_redshift_subnet_group" "default" {
  for_each   = var.redshift_cluster
  name       = each.value.rshift_subnet_group
  subnet_ids = each.value.rshift_subnet_group_subnet_ids
  tags       = each.value.tags
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
  cluster_subnet_group_name           = aws_redshift_subnet_group.default[each.key].id
  cluster_parameter_group_name        = each.value.cluster_parameter_group_name
  vpc_security_group_ids              = [aws_security_group.default["ospr-coin-redshift-sg"].id, data.aws_security_group.cloudvpn.id]
  skip_final_snapshot                 = each.value.skip_final_snapshot
  tags                                = each.value.tags
  iam_roles                           = each.value.iam_roles
  publicly_accessible                 = each.value.publicly_accessible
}


resource "aws_redshift_parameter_group" "par" {
  for_each = var.rshift_para_group
  name     = each.value.name
  family   = each.value.family
  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }
}
##### Redshift cluster configuration configuration details end #####
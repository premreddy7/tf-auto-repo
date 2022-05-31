##### Glue configuration configuration details begin #####

resource "aws_glue_connection" "incorta_conn" {
  for_each = var.glue_conn_details
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:${each.value.engine}://${each.value.host}:${each.value.port}/${each.value.dbname}"
    PASSWORD            = each.value.password
    USERNAME            = each.value.username
  }

  name = each.value.name

  physical_connection_requirements {
    availability_zone      = each.value.az
    security_group_id_list = [aws_security_group.default["ospr-coin-incorta_sg"].id]
    subnet_id              = each.value.subnet_id

  }
  lifecycle {
    ignore_changes = all
  }
}
##### Glue configuration configuration details end #####
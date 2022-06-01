##### Transport Proxy Instances configuration configuration details begin #####
resource "aws_instance" "default" {
  for_each                = var.instance_details
  ami                     = each.value.ec2_ami
  instance_type           = each.value.instance_type
  iam_instance_profile    = each.value.iam_instance_profile
  disable_api_termination = each.value.disable_api_termination
  ebs_optimized           = each.value.ebs_optimized
  get_password_data       = each.value.get_password_data
  hibernation             = each.value.hibernation
  monitoring              = each.value.monitoring

  user_data = file(each.value.user_data)

  network_interface {
    network_interface_id = each.value.ec2_network_interface_id
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
  tags = each.value.ec2_tag
}
##### Transport Proxy Instances configuration configuration details end #####

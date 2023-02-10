locals {
  ssh_username = element(split("/", data.aws_ssm_parameter.ssh_credentials.value ), 0)
  ssh_password = element(split("/", data.aws_ssm_parameter.ssh_credentials.value ), 1)
}

locals {
  SPOT_INSTANCE_ID =aws_spot_instance_request.SPOT.*.spot_instance_id
  //ONDEMAND_INSTANE_ID = aws_instance.ondemand.*.id
  //ALL_INSTANCE_ID = concat(local.SPOT_INSTANCE_ID, local.ONDEMAND_INSTANE_ID)
  ALL_INSTANCE_ID = concat(local.SPOT_INSTANCE_ID)
  SPOT_PRIVATE_IP = aws_spot_instance_request.SPOT.*.private_ip
  //ONDEMAND_PRIVATE_IP = aws_instance.ondemand.*.private_ip
  //ALL_PRIVATE_IP = concat(local.SPOT_PRIVATE_IP,local.ONDEMAND_PRIVATE_IP)
  ALL_PRIVATE_IP = concat(local.SPOT_PRIVATE_IP)

}

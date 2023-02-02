resource "aws_instance" "ondemand" {
  count = var.instances["ONDEMAND"].instance_count
  instance_type = var.instances["ONDEMAND"].instance_type
  ami = data.aws_ami.ami.image_id
  subnet_id = data.terraform_remote_state.infra.outputs.app_subnets[count.index]

}
resource "aws_spot_instance_request" "SPOT" {
  count = var.instances["SPOT"].instance_count
  instance_type = var.instances["SPOT"].instance_type
  ami = data.aws_ami.ami.image_id
  subnet_id = data.terraform_remote_state.infra.outputs.app_subnets[count.index]
  #wait_for_fulfillment = true
  tags = {
    Name = "cart-${var.ENV}"

  }
}
locals {
  SPOT_INSTANCE_ID =aws_spot_instance_request.SPOT.*.spot_instance_id
  ONDEMAND_INSTANE_ID = aws_instance.ondemand.*.id
  ALL_INSTANCE_ID = concat(local.SPOT_INSTANCE_ID, local.ONDEMAND_INSTANE_ID)
}
resource "aws_ec2_tag" "name" {
  count = length(local.ALL_INSTANCE_ID)
  resource_id = element(local.ALL_INSTANCE_ID, count.index)
  key = "Name"
  value = "${var.COMPONENT}-${var.ENV}"

}
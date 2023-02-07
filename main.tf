resource "aws_instance" "ondemand" {
  count = var.instances["ONDEMAND"].instance_count
  instance_type = var.instances["ONDEMAND"].instance_type
  ami = data.aws_ami.ami.image_id
  subnet_id = data.terraform_remote_state.infra.outputs.app_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile = aws_iam_instance_profile.parameter-store-access.name

}
resource "aws_spot_instance_request" "SPOT" {
  count = var.instances["SPOT"].instance_count
  instance_type = var.instances["SPOT"].instance_type
  ami = data.aws_ami.ami.image_id
  subnet_id = data.terraform_remote_state.infra.outputs.app_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.main.id]
  wait_for_fulfillment = true
  tags = {
    Name = "rabbimq-${var.ENV}"
  }
  }

resource "aws_ec2_tag" "name" {
  count = length(local.ALL_INSTANCE_ID)
  resource_id = element(local.ALL_INSTANCE_ID, count.index)
  key = "Name"
  value = "${var.COMPONENT}-${var.ENV}"

}

resource "null_resource" "ansible_apply" {
  depends_on = [aws_instance.ondemand, aws_spot_instance_request.SPOT]
  count = length(local.ALL_PRIVATE_IP)
  provisioner "remote-exec" {
    connection {
      host = element(local.ALL_PRIVATE_IP, count.index)
      user = local.ssh_username
      password = local.ssh_password
    }
    inline = [
       "ansible-pull -i localhost, -U https://github.com/prasanthbangs2016/roboshop-mutable-ansible--v2 roboshop.yml -e HOSTS=localhost -e APP_COMPONENT_ROLE=${var.COMPONENT} -e ENV=${var.ENV}"
    ]
  }
}

resource "aws_security_group" "main" {
  name        = "roboshop-${var.ENV}-${var.COMPONENT}"
  description = "roboshop-${var.ENV}--${var.COMPONENT}"
    vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id
  #to instance
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [data.terraform_remote_state.infra.outputs.vpc_cidr,data.terraform_remote_state.infra.outputs.WORKSTATION_IP]

  }
  #outbound from instance
  egress {
    description      = "egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }


  tags = {
    Name = "Roboshop-${var.ENV}-cart"
  }
}
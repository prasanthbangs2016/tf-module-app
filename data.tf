data "aws_ssm_parameter" "ssh_credentials" {
  name = "ssh_credentials"

}

data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "centos-devops-practice-ansible"
  owners           = ["self"]

  #  filter {
  #    name   = "name"
  #    values = ["myami-*"]
  #  }
  #
  #  filter {
  #    name   = "root-device-type"
  #    values = ["ebs"]
  #  }
  #
  #  filter {
  #    name   = "virtualization-type"
  #    values = ["hvm"]
  #  }
}
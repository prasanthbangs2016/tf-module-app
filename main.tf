resource "aws_instance" "ondemand" {
  count = var.instances["ONDEMAND"].instance_count
  instance_type = var.instances["ONDEMAND"].instance_type
  ami = data.aws_ami.ami.image_id

}
resource "aws_instance" "SPOT" {
  count = var.instances["SPOT"].instance_count
  instance_type = var.instances["SPOT"].instance_type
  ami = data.aws_ami.ami.image_id
  wait_for_fulfillment = true
  tags = {
    Name = "cart-${var.ENV}"

  }
}
resource "aws_lb_target_group_attachment" "test" {
  #as i want target group arn so export info into outputs from alb module
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.test.id
  port             = 80
}
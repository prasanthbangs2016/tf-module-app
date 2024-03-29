resource "aws_lb_target_group_attachment" "tg" {
  #as i want target group arn so export info into outputs from alb module and that referenced in infra module
  #and, as statefile will have info so will reference from it
  #target group should attach only when it is frontend
  #hence the condition tgt group arn = frontend else target group arn
  count = length(local.ALL_INSTANCE_ID)
  target_group_arn = var.COMPONENT == "frontend" ? data.terraform_remote_state.infra.outputs.public_tg_arn : aws_lb_target_group.tg[0].arn
  target_id        = local.ALL_INSTANCE_ID[count.index]
  port             = var.APP_PORT
}

resource "aws_lb_target_group" "tg" {
  #create tg if not == frontend
  count = var.COMPONENT == "frontend" ? 0 : 1
  name     = "${var.COMPONENT}-${var.ENV}"
  # target group backend is opened with 80port hence the same"
  port     = var.APP_PORT
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.infra.outputs.vpc_id
  deregistration_delay = 0
  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 5
    timeout = 4
    port = var.APP_PORT
    unhealthy_threshold = 2
    #/health is available for the services
    #curl - L
    path = "/health"

  }
}

#private lb listener rule for backend services routing
resource "aws_lb_listener_rule" "name-based-rule" {
  #create if not == frontend
  count = var.COMPONENT == "frontend" ? 0 : 1
  listener_arn = data.terraform_remote_state.infra.outputs.private_lb_listener_arn
  priority     = var.LB_RULE_PRIORITY

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }

  condition {
    host_header {
      values = ["${var.COMPONENT}-${var.ENV}.roboshop.internal"]
    }
  }

}

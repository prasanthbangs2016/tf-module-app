resource "aws_lb_target_group_attachment" "tg" {
  #as i want target group arn so export info into outputs from alb module and that referenced in infra module
  #and, as statefile will have info so will reference from it
  #target group should attach only when it is frontend
  #hence the condition tgt group arn = frontend else target group arn
  count = length(local.ALL_INSTANCE_ID)
  target_group_arn = var.COMPONENT == "frontend" ? data.terraform_remote_state.infra.outputs.public_tg_arn : aws_lb_target_group.tg.arn
  target_id        = local.ALL_INSTANCE_ID[count.index]
  port             = var.APP_PORT
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.COMPONENT}-${var.ENV}-tg"
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
    path = "/health"

  }
}

resource "aws_lb_target_group_attachment" "test" {
  #as i want target group arn so export info into outputs from alb module and that referenced in infra module
  #and, as statefile will have info so will reference from it
  count = length(local.ALL_INSTANCE_ID)
  target_group_arn = data.terraform_remote_state.infra.outputs.public_tg_arn
  target_id        = local.ALL_INSTANCE_ID
  port             = 80
}
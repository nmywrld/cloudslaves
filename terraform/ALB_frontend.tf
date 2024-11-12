resource "aws_lb" "frontend_app_lb" {
  name               = "frontend-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb_sg.id]
  subnets            = aws_subnet.frontend_public[*].id
}

resource "aws_lb_target_group" "frontend_ecs_tg" {
  name        = "frontend-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.frontend.id
  target_type = "ip"
}

resource "aws_lb_listener" "frontend_public_http" {
  load_balancer_arn = aws_lb.frontend_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_ecs_tg.arn
  }
  depends_on = [aws_lb.frontend_app_lb, aws_lb_target_group.frontend_ecs_tg]

}
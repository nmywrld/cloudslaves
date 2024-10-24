resource "aws_lb" "private_app_lb" {
  name               = "private-app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.private[*].id
}

resource "aws_lb_target_group" "lambda_tg" {
  name        = "lambda-tg"
  target_type = "lambda"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "private-http" {
  load_balancer_arn = aws_lb.private_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}
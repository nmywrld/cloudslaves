resource "aws_lb" "backend_app_lb" {
  name               = "backend-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb_sg.id]
  subnets            = aws_subnet.backend_public[*].id

  enable_cross_zone_load_balancing            = true
  enable_http2                                = true
  idle_timeout                                = 60
  ip_address_type                             = "ipv4"

  
}

resource "aws_lb_target_group" "backend_lambda_tg" {
  name        = "lambda-tg"
  target_type = "lambda"
  vpc_id      = aws_vpc.backend.id
}

resource "aws_lb_listener" "backend_private_http" {
  load_balancer_arn = aws_lb.backend_app_lb.arn
  # port              = 80
  # protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_lambda_tg.arn
  }

}


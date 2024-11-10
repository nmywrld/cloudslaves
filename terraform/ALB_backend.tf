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
  port          = 80        # The port is not relevant for Lambda, but it's still required by the ALB configuration
  protocol      = "HTTP"    # Protocol for the target group (again, HTTP is used here, but it doesn't affect Lambda)
  # vpc_id      = aws_vpc.backend.id
}
# Reference the load balancer ARN after it is created
output "load_balancer_arn" {
  value = aws_lb.backend_app_lb.arn
}

resource "aws_lb_listener" "backend_private_http" {
  load_balancer_arn = aws_lb.backend_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_lambda_tg.arn
  }
  depends_on = [aws_lb.backend_app_lb, aws_lb_target_group.backend_lambda_tg]

}

output "load_balancer_arn123" {
  value = aws_lb.backend_app_lb.arn
}





# Step 6: Lambda permission to allow ALB to invoke the Lambda function
resource "aws_lambda_permission" "allow_alb_invoke" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.another_lambda_tg.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb.backend_app_lb.arn
}